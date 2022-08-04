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
    let store = createFreshUsersStore(identifier: identifier, directory: directory)
    XCTAssertEqual(store.uniqueIdentifier, identifier)
    XCTAssertEqual(store.directory, directory)
  }

  func testSaveObject() throws {
    let store = createFreshUsersStore()

    try store.save(.john)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.object(withId: User.john.id), .john)
    XCTAssertEqual(store.allObjects(), [.john])

    XCTAssertEqual(try allUsers(), [.john])
  }

  func testSaveOptional() throws {
    let store = createFreshUsersStore()

    try store.save(nil)
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(try allUsers().isEmpty)

    try store.save(.john)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.john])
    XCTAssertEqual(try allUsers(), [.john])
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
    let users: Set<User> = [.john, .johnson, .james]

    try store.save(Array(users))
    XCTAssertEqual(store.objectsCount, 3)
    XCTAssertEqual(Set(store.allObjects()), users)
    XCTAssertEqual(try allUsers(), users)
  }

  func testSaveInvalidObjects() {
    let store = createFreshUsersStore()

    XCTAssertThrowsError(try store.save([.james, .john, .invalid]))
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssertEqual(store.allObjects(), [])
    XCTAssert(try allUsers().isEmpty)
  }

  func testObject() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(.johnson))
    XCTAssertEqual(store.object(withId: User.johnson.id), .johnson)
    XCTAssertEqual(try allUsers(), [.johnson])

    XCTAssertNil(store.object(withId: 123))
    XCTAssertEqual(try allUsers(), [.johnson])
  }

  func testObjects() {
    let store = createFreshUsersStore()
    XCTAssertNoThrow(try store.save([.john, .james]))
    XCTAssertEqual(store.objects(withIds: [User.john.id, User.james.id, 5]), [.john, .james])
    XCTAssertEqual(try allUsers(), [.john, .james])
  }

  func testAllObjects() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(.john))
    XCTAssertEqual(Set(store.allObjects()), [.john])
    XCTAssertEqual(try allUsers(), [.john])

    XCTAssertNoThrow(try store.save(.johnson))
    XCTAssertEqual(Set(store.allObjects()), [.john, .johnson])
    XCTAssertEqual(try allUsers(), [.john, .johnson])

    XCTAssertNoThrow(try store.save(.james))
    XCTAssertEqual(Set(store.allObjects()), [.john, .johnson, .james])
    XCTAssertEqual(try allUsers(), [.john, .johnson, .james])
  }

  func testRemoveObject() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(.james))
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.james])
    XCTAssertEqual(try allUsers(), [.james])

    store.remove(withId: 123)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.james])
    XCTAssertEqual(try allUsers(), [.james])

    store.remove(withId: User.james.id)
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
    XCTAssert(try allUsers().isEmpty)
  }

  func testRemoveObjects() {
    let store = createFreshUsersStore()
    XCTAssertNoThrow(try store.save(.james))
    XCTAssertNoThrow(try store.save(.johnson))
    XCTAssertEqual(store.objectsCount, 2)
    XCTAssertEqual(Set(store.allObjects()), [.james, .johnson])

    store.remove(withIds: [User.james.id, 5, 6, 8])
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.johnson])
    XCTAssertEqual(try allUsers(), [.johnson])
  }

  func testRemoveAll() {
    let store = createFreshUsersStore()
    XCTAssertNoThrow(try store.save(.john))
    XCTAssertNoThrow(try store.save(.johnson))
    XCTAssertNoThrow(try store.save(.james))

    store.removeAll()
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
    XCTAssert(try allUsers().isEmpty)
  }

  func testContainsObject() {
    let store = createFreshUsersStore()
    XCTAssertFalse(store.containsObject(withId: 10))

    XCTAssertNoThrow(try store.save(.john))
    XCTAssert(store.containsObject(withId: User.john.id))
  }

  func testUpdatingSameObjectDoesNotChangeCount() throws {
    let store = createFreshUsersStore()

    let users: [User] = [.john, .johnson, .james]
    try store.save(users)

    var john = User.john
    for i in 0..<10 {
      john.firstName = "\(i)"
      try store.save(john)
    }

    XCTAssertEqual(store.objectsCount, users.count)
    XCTAssertEqual(try allUsers().count, users.count)
  }

  func testThreadSafety() throws {
    let store = createFreshUsersStore()
    let expectation1 = XCTestExpectation(description: "Store has 1000 items.")
    for i in 0..<1_000 {
      Thread.detachNewThread {
        let user = User(id: i, firstName: "", lastName: "", age: .random(in: 1..<90))
        try? store.save(user)
      }
    }
    Thread.sleep(forTimeInterval: 2)
    let allUsersCount1 = try allUsers().count
    if store.objectsCount == 1_000 && allUsersCount1 == 1_000 {
      expectation1.fulfill()
    }

    let expectation2 = XCTestExpectation(description: "Store has 500 items.")
    for i in 0..<500 {
      Thread.detachNewThread {
        store.remove(withId: i)
      }
    }
    Thread.sleep(forTimeInterval: 2)
    let allUsersCount2 = try allUsers().count
    if store.objectsCount == 500 && allUsersCount2 == 500 {
      expectation2.fulfill()
    }

    wait(for: [expectation1, expectation2], timeout: 5)
  }
}

// MARK: - Helpers

private extension MultiFileSystemStoreTests {
  func storeURL(identifier: String = "users", directory: FileManager.SearchPathDirectory = .cachesDirectory) throws -> URL {
    return try manager.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
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
    let store = MultiFileSystemStore<User>(uniqueIdentifier: identifier, directory: directory)
    store.removeAll()
    return store
  }
}
