@testable import FileSystemStore
@testable import TestUtils

import Foundation
import XCTest

final class SingleFileSystemStoreTests: XCTestCase {
  private var store: SingleFileSystemStore<User>?
  private let manager = FileManager.default

  override func tearDownWithError() throws {
    try store?.remove()
  }

  func testCreateStore() {
    let directory = FileManager.SearchPathDirectory.documentDirectory
    let path = UUID().uuidString
    let store = createFreshUserStore(directory: directory, path: path)
    XCTAssertEqual(store.directory, directory)
    XCTAssertEqual(store.path, path)
  }

  func testDeprecatedCreateStore() {
    let identifier = UUID().uuidString
    let directory = FileManager.SearchPathDirectory.documentDirectory
    let store = SingleFileSystemStore<User>(
      identifier: identifier,
      directory: directory
    )
    XCTAssertEqual(identifier, store.identifier)
    XCTAssertEqual(directory, store.directory)
    self.store = store
  }

  func testSaveObject() throws {
    let path = UUID().uuidString
    let store = createFreshUserStore(path: path)

    try store.save(User.ahmad)
    XCTAssertNotNil(store.object)
    XCTAssertEqual(store.object(), User.ahmad)

    let url = try url(path: path)
    let data = try Data(contentsOf: url)
    let decodedUser = try JSONDecoder().decode(User.self, from: data)
    XCTAssertEqual(store.object(), decodedUser)

    try store.save(nil)
    XCTAssertNil(store.object())
    XCTAssertFalse(manager.fileExists(atPath: url.path))
  }

  func testSaveInvalidObject() {
    let store = createFreshUserStore()
    XCTAssertThrowsError(try store.save(User.invalid))
  }

  func testObject() throws {
    let store = createFreshUserStore()

    try store.save(User.dalia)
    XCTAssertNotNil(store.object())
  }

  func testObjectIsLoggingErrors() throws {
    let store = createFreshUserStore()

    let storePath = try storeURL().path
    if manager.fileExists(atPath: storePath) == false {
      try manager.createDirectory(
        atPath: storePath,
        withIntermediateDirectories: true
      )
    }

    let path = try url().path
    let invalidData = "test".data(using: .utf8)!
    manager.createFile(atPath: path, contents: invalidData)
    XCTAssertNil(store.object())
    XCTAssertEqual(
      store.logger.lastOutput,
      """
      An error occurred in `SingleFileSystemStore.object()`. Error: The data \
      couldn’t be read because it isn’t in the correct format.
      """
    )
  }

  func testRemove() throws {
    let path = UUID().uuidString
    let store = createFreshUserStore(path: path)

    try store.save(User.ahmad)
    XCTAssertNotNil(store.object)
    XCTAssertEqual(store.object(), User.ahmad)

    try store.remove()

    let url = try url(path: path)
    XCTAssertFalse(manager.fileExists(atPath: url.path))
  }
}

// MARK: - Helpers

private extension SingleFileSystemStoreTests {
  func storeURL(
    directory: FileManager.SearchPathDirectory = .cachesDirectory,
    path: String = "user"
  ) throws -> URL {
    return try manager.url(
      for: directory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    .appendingPathComponent("Stores", isDirectory: true)
    .appendingPathComponent("SingleObject", isDirectory: true)
    .appendingPathComponent(path, isDirectory: true)
  }

  func url(
    directory: FileManager.SearchPathDirectory = .cachesDirectory,
    path: String = "user"
  ) throws -> URL {
    return try storeURL(directory: directory, path: path)
      .appendingPathComponent("object")
      .appendingPathExtension("json")
  }

  func createFreshUserStore(
    directory: FileManager.SearchPathDirectory = .cachesDirectory,
    path: String = "user"
  ) -> SingleFileSystemStore<User> {
    let store = SingleFileSystemStore<User>(directory: directory, path: path)
    XCTAssertEqual(path, store.identifier)
    XCTAssertNoThrow(try store.remove())
    self.store = store
    return store
  }
}
