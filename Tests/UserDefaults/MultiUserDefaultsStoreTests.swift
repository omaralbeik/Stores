@testable import UserDefaultsStore
@testable import TestUtils

import Foundation
import XCTest

final class MultiUserDefaultsStoreTests: XCTestCase {
  func testCreateStore() {
    let identifier = UUID().uuidString
    let store = createFreshUsersStore(identifier: identifier)
    XCTAssertEqual(store.uniqueIdentifier, identifier)
  }

  func testSaveObject() throws {
    let store = createFreshUsersStore()

    try store.save(.ahmad)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.ahmad])
    XCTAssertEqual(allUsersInStore(), [.ahmad])
  }

  func testSaveOptional() throws {
    let store = createFreshUsersStore()

    try store.save(nil)
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(allUsersInStore().isEmpty)

    try store.save(.ahmad)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.ahmad])
    XCTAssertEqual(allUsersInStore(), [.ahmad])
  }

  func testSaveInvalidObject() {
    let store = createFreshUsersStore()
    let optionalUser: User? = .invalid

    XCTAssertThrowsError(try store.save(.invalid))
    XCTAssertThrowsError(try store.save(optionalUser))
    XCTAssert(store.allObjects().isEmpty)
    XCTAssert(allUsersInStore().isEmpty)
  }

  func testSaveObjects() throws {
    let store = createFreshUsersStore()
    let users: Set<User> = [.ahmad, .dalia, .kareem]

    try store.save(Array(users))
    XCTAssertEqual(store.objectsCount, 3)
    XCTAssertEqual(Set(store.allObjects()), users)
    XCTAssertEqual(allUsersInStore(), users)
  }

  func testSaveInvalidObjects() {
    let store = createFreshUsersStore()

    XCTAssertThrowsError(try store.save([.kareem, .ahmad, .invalid]))
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssertEqual(store.allObjects(), [])
    XCTAssert(allUsersInStore().isEmpty)
  }

  func testObject() throws {
    let store = createFreshUsersStore()

    try store.save(.dalia)
    XCTAssertEqual(store.object(withId: User.dalia.id), .dalia)
    XCTAssertEqual(allUsersInStore(), [.dalia])

    XCTAssertNil(store.object(withId: 123))
    XCTAssertEqual(allUsersInStore(), [.dalia])
  }

  func testObjects() throws {
    let store = createFreshUsersStore()
    try store.save([.ahmad, .kareem])
    XCTAssertEqual(
      store.objects(withIds: [User.ahmad.id, User.kareem.id, 5]),
      [.ahmad, .kareem]
    )
    XCTAssertEqual(allUsersInStore(), [.ahmad, .kareem])
  }

  func testAllObjects() throws {
    let store = createFreshUsersStore()

    try store.save(.ahmad)
    XCTAssertEqual(Set(store.allObjects()), [.ahmad])
    XCTAssertEqual(allUsersInStore(), [.ahmad])

    try store.save(.dalia)
    XCTAssertEqual(Set(store.allObjects()), [.ahmad, .dalia])
    XCTAssertEqual(allUsersInStore(), [.ahmad, .dalia])

    try store.save(.kareem)
    XCTAssertEqual(Set(store.allObjects()), [.ahmad, .dalia, .kareem])
    XCTAssertEqual(allUsersInStore(), [.ahmad, .dalia, .kareem])
  }

  func testRemoveObject() throws {
    let store = createFreshUsersStore()

    try store.save(.kareem)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.kareem])
    XCTAssertEqual(allUsersInStore(), [.kareem])

    store.remove(withId: 123)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.kareem])
    XCTAssertEqual(allUsersInStore(), [.kareem])

    store.remove(withId: User.kareem.id)
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
    XCTAssert(allUsersInStore().isEmpty)
  }

  func testRemoveObjects() throws {
    let store = createFreshUsersStore()
    try store.save(.kareem)
    try store.save(.dalia)
    XCTAssertEqual(store.objectsCount, 2)
    XCTAssertEqual(Set(store.allObjects()), [.kareem, .dalia])

    store.remove(withIds: [User.kareem.id, 5, 6, 8])
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.dalia])
    XCTAssertEqual(allUsersInStore(), [.dalia])
  }

  func testRemoveAll() throws {
    let store = createFreshUsersStore()
    try store.save(.ahmad)
    try store.save(.dalia)
    try store.save(.kareem)

    store.removeAll()
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
    XCTAssert(allUsersInStore().isEmpty)
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
    XCTAssertEqual(count(), users.count)
  }

  func testThreadSafety() {
    let store = createFreshUsersStore()
    let expectation1 = XCTestExpectation(description: "Store has 1000 items.")
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
    if store.objectsCount == 200 && allUsersInStore().count == 200 {
      expectation1.fulfill()
    }

    let expectation2 = XCTestExpectation(description: "Store has 100 items.")
    for i in 0..<100 {
      Thread.detachNewThread {
        store.remove(withId: i)
      }
    }
    Thread.sleep(forTimeInterval: 2)
    if store.objectsCount == 100 && allUsersInStore().count == 100 {
      expectation2.fulfill()
    }

    wait(for: [expectation1, expectation2], timeout: 5)
  }
}

// MARK: - Helpers

private extension MultiUserDefaultsStoreTests {
  func createFreshUsersStore(
    identifier: String = "users"
  ) -> MultiUserDefaultsStore<User> {
    let store = MultiUserDefaultsStore<User>(uniqueIdentifier: identifier)
    store.removeAll()
    return store
  }

  func allUsersInStore(with identifier: String = "users") -> Set<User> {
    guard let store = UserDefaults(suiteName: identifier) else { return [] }
    let users = store.dictionaryRepresentation()
      .values
      .compactMap { $0 as? Data }
      .compactMap { try? JSONDecoder().decode(User.self, from: $0) }
    return Set(users)
  }

  func count(identifier: String = "users") -> Int {
    return UserDefaults(suiteName: identifier)?
      .integer(forKey: "\(identifier)-count") ?? 0
  }
}
