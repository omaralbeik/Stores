@testable import FileSystemStore
@testable import TestUtils

import Foundation
import XCTest

final class MultiFileSystemStoreTests: XCTestCase {
  private let manager = FileManager.default
  private let decoder = JSONDecoder()

  func testCreateStore() {
    let identifier = UUID().uuidString
    let directory = FileManager.SearchPathDirectory.documentDirectory
    let store = createFreshUsersStore(
      identifier: identifier,
      directory: directory
    )
    XCTAssertEqual(store.identifier, identifier)
    XCTAssertEqual(store.directory, directory)
  }

  func testSaveObject() throws {
    let store = createFreshUsersStore()

    try store.save(.ahmad)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.object(withId: User.ahmad.id), .ahmad)
    XCTAssertEqual(store.allObjects(), [.ahmad])

    XCTAssertEqual(try allUsers(), [.ahmad])
  }

  func testSaveOptional() throws {
    let store = createFreshUsersStore()

    try store.save(nil)
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(try allUsers().isEmpty)

    try store.save(.ahmad)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.ahmad])
    XCTAssertEqual(try allUsers(), [.ahmad])
  }

  func testSaveInvalidObject() {
    let store = createFreshUsersStore()
    let optionalUser: User? = .invalid

    XCTAssertThrowsError(try store.save(.invalid))
    XCTAssertThrowsError(try store.save(optionalUser))
    XCTAssert(store.allObjects().isEmpty)
    XCTAssert(try allUsers().isEmpty)
  }

  func testSaveObjects() throws {
    let store = createFreshUsersStore()
    let users: Set<User> = [.ahmad, .dalia, .kareem]

    try store.save(Array(users))
    XCTAssertEqual(store.objectsCount, 3)
    XCTAssertEqual(Set(store.allObjects()), users)
    XCTAssertEqual(try allUsers(), users)

    try store.removeAll()

    try store.save(users)
    XCTAssertEqual(store.objectsCount, 3)
    XCTAssertEqual(Set(store.allObjects()), users)
    XCTAssertEqual(try allUsers(), users)
  }

  func testSaveInvalidObjects() {
    let store = createFreshUsersStore()

    XCTAssertThrowsError(try store.save([.kareem, .ahmad, .invalid]))
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssertEqual(store.allObjects(), [])
    XCTAssert(try allUsers().isEmpty)
  }

  func testObject() throws {
    let store = createFreshUsersStore()

    try store.save(.dalia)
    XCTAssertEqual(store.object(withId: User.dalia.id), .dalia)
    XCTAssertEqual(try allUsers(), [.dalia])

    XCTAssertNil(store.object(withId: 123))
    XCTAssertEqual(try allUsers(), [.dalia])
  }

  func testObjectLogging() throws {
    let store = createFreshUsersStore()
    try store.save(.ahmad)
    let url = try url(forUser: .ahmad)
    let data = "{]".data(using: .utf8)!
    try data.write(to: url)

    let user = store.object(withId: User.ahmad.id)
    XCTAssertNil(user)
    XCTAssertEqual(
      store.logger.lastOutput,
      """
      An error occurred in `MultiFileSystemStore.object(withId:)`. \
      Error: The data couldn’t be read because it isn’t in the correct format.
      """
    )
  }

  func testObjects() throws {
    let store = createFreshUsersStore()
    try store.save([.ahmad, .kareem])
    XCTAssertEqual(
      store.objects(withIds: [User.ahmad.id, User.kareem.id, 5]),
      [.ahmad, .kareem]
    )
    XCTAssertEqual(try allUsers(), [.ahmad, .kareem])
  }

  func testAllObjectsLogging() throws {
    let store = createFreshUsersStore()
    try store.save([.ahmad, .dalia, .kareem])
    let url = try url(forUser: .dalia)
    let data = "{]".data(using: .utf8)!
    try data.write(to: url)

    XCTAssertEqual(store.allObjects(), [.ahmad, .kareem])
    XCTAssertEqual(
      store.logger.lastOutput,
      """
      An error occurred in `MultiFileSystemStore.allObjects()`. \
      Error: The data couldn’t be read because it isn’t in the correct format.
      """
    )
  }

  func testAllObjects() throws {
    let store = createFreshUsersStore()

    try store.save(.ahmad)
    XCTAssertEqual(Set(store.allObjects()), [.ahmad])
    XCTAssertEqual(try allUsers(), [.ahmad])

    try store.save(.dalia)
    XCTAssertEqual(Set(store.allObjects()), [.ahmad, .dalia])
    XCTAssertEqual(try allUsers(), [.ahmad, .dalia])

    try store.save(.kareem)
    XCTAssertEqual(Set(store.allObjects()), [.ahmad, .dalia, .kareem])
    XCTAssertEqual(try allUsers(), [.ahmad, .dalia, .kareem])
  }

  func testRemoveObject() throws {
    let store = createFreshUsersStore()

    try store.save(.kareem)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.kareem])
    XCTAssertEqual(try allUsers(), [.kareem])

    try store.remove(withId: 123)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.kareem])
    XCTAssertEqual(try allUsers(), [.kareem])

    try store.remove(withId: User.kareem.id)
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
    XCTAssert(try allUsers().isEmpty)
  }

  func testRemoveObjects() throws {
    let store = createFreshUsersStore()
    try store.save(.kareem)
    try store.save(.dalia)
    XCTAssertEqual(store.objectsCount, 2)
    XCTAssertEqual(Set(store.allObjects()), [.kareem, .dalia])

    try store.remove(withIds: [User.kareem.id, 5, 6, 8])
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.dalia])
    XCTAssertEqual(try allUsers(), [.dalia])
  }

  func testRemoveAll() throws {
    let store = createFreshUsersStore()
    try store.save(.ahmad)
    try store.save(.dalia)
    try store.save(.kareem)

    try store.removeAll()
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
    XCTAssert(try allUsers().isEmpty)
  }

  func testContainsObject() throws {
    let store = createFreshUsersStore()
    XCTAssertFalse(store.containsObject(withId: 10))

    try store.save(.ahmad)
    XCTAssert(store.containsObject(withId: User.ahmad.id))
  }

  func testUpdatingSameObjectDoesNotChangeCount() throws {
    let store = createFreshUsersStore()

    let users: [User] = [.ahmad, .dalia, .kareem]
    try store.save(users)

    var user = User.ahmad
    for i in 0..<10 {
      user.firstName = "\(i)"
      try store.save(user)
    }

    XCTAssertEqual(store.objectsCount, users.count)
    XCTAssertEqual(try allUsers().count, users.count)
  }

  func testThreadSafety() throws {
    let store = createFreshUsersStore()
    let expectation1 = XCTestExpectation(description: "Store has 200 items.")
    for i in 0..<200 {
      Thread.detachNewThread {
        let user = User(
          id: i,
          firstName: "",
          lastName: "",
          age: .random(in: 1..<90)
        )
        try? store.save(user)
      }
    }
    Thread.sleep(forTimeInterval: 2)
    let allUsersCount1 = try allUsers().count
    if store.objectsCount == 200 && allUsersCount1 == 200 {
      expectation1.fulfill()
    }

    let expectation2 = XCTestExpectation(description: "Store has 100 items.")
    for i in 0..<100 {
      Thread.detachNewThread {
        try? store.remove(withId: i)
      }
    }
    Thread.sleep(forTimeInterval: 2)
    let allUsersCount2 = try allUsers().count
    if store.objectsCount == 100 && allUsersCount2 == 100 {
      expectation2.fulfill()
    }

    wait(for: [expectation1, expectation2], timeout: 5)
  }
}

// MARK: - Helpers

private extension MultiFileSystemStoreTests {
  func storeURL(
    identifier: String = "users",
    directory: FileManager.SearchPathDirectory = .cachesDirectory
  ) throws -> URL {
    return try manager.url(
      for: directory,
      in: .userDomainMask,
      appropriateFor: nil,
      create: true
    )
    .appendingPathComponent("Stores", isDirectory: true)
    .appendingPathComponent("MultiObjects", isDirectory: true)
    .appendingPathComponent(identifier, isDirectory: true)
  }

  func url(forUserWithId id: User.ID) throws -> URL {
    return try storeURL()
      .appendingPathComponent("\(id)")
      .appendingPathExtension("json")
  }

  func url(forUser user: User) throws -> URL {
    return try url(forUserWithId: user.id)
  }

  func url(forUserPath userPath: String) throws -> URL {
    return try storeURL()
      .appendingPathComponent(userPath, isDirectory: false)
  }

  func user(atPath path: String) throws -> User? {
    guard let data = manager.contents(atPath: path) else { return nil }
    return try decoder.decode(User.self, from: data)
  }

  func allUsers() throws -> Set<User> {
    let storePath = try storeURL().path
    if manager.fileExists(atPath: storePath) == false {
      try manager.createDirectory(
        atPath: storePath,
        withIntermediateDirectories: true
      )
    }
    let users = try manager.contentsOfDirectory(atPath: storePath)
      .compactMap(url(forUserPath:))
      .map(\.path)
      .compactMap(user(atPath:))
    return Set(users)
  }

  func createFreshUsersStore(
    identifier: String = "users",
    directory: FileManager.SearchPathDirectory = .cachesDirectory
  ) -> MultiFileSystemStore<User> {
    let store = MultiFileSystemStore<User>(
      identifier: identifier,
      directory: directory
    )
    store.logger.printEnabled = false
    XCTAssertNoThrow(try store.removeAll())
    return store
  }
}
