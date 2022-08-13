@testable import FileSystemStore
@testable import TestUtils

import Foundation
import XCTest

final class SingleFileSystemStoreTests: XCTestCase {
  private let manager = FileManager.default

  func testCreateStore() {
    let identifier = UUID().uuidString
    let directory = FileManager.SearchPathDirectory.documentDirectory
    let store = createFreshUserStore(
      identifier: identifier,
      directory: directory
    )
    XCTAssertEqual(store.identifier, identifier)
    XCTAssertEqual(store.directory, directory)
  }

  func testSaveObject() throws {
    let identifier = UUID().uuidString
    let store = createFreshUserStore(identifier: identifier)

    try store.save(User.ahmad)
    XCTAssertNotNil(store.object)
    XCTAssertEqual(store.object(), User.ahmad)

    let url = try url(identifier: identifier)
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
    let identifier = UUID().uuidString
    let store = createFreshUserStore(identifier: identifier)

    try store.save(User.ahmad)
    XCTAssertNotNil(store.object)
    XCTAssertEqual(store.object(), User.ahmad)

    try store.remove()

    let url = try url(identifier: identifier)
    XCTAssertFalse(manager.fileExists(atPath: url.path))
  }
}

// MARK: - Helpers

private extension SingleFileSystemStoreTests {
  func storeURL(
    identifier: String = "user",
    directory: FileManager.SearchPathDirectory = .cachesDirectory
  ) throws -> URL {
    return try manager.url(
      for: directory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    .appendingPathComponent("Stores", isDirectory: true)
    .appendingPathComponent("SingleObject", isDirectory: true)
    .appendingPathComponent(identifier, isDirectory: true)
  }

  func url(
    identifier: String = "user",
    directory: FileManager.SearchPathDirectory = .cachesDirectory
  ) throws -> URL {
    return try storeURL(identifier: identifier, directory: directory)
      .appendingPathComponent("object")
      .appendingPathExtension("json")
  }

  func createFreshUserStore(
    identifier: String = "user",
    directory: FileManager.SearchPathDirectory = .cachesDirectory
  ) -> SingleFileSystemStore<User> {
    let store = SingleFileSystemStore<User>(
      identifier: identifier,
      directory: directory
    )
    store.logger.printEnabled = false
    XCTAssertNoThrow(try store.remove())
    return store
  }
}
