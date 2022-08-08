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

    try store.save(.john)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.john])
    XCTAssertEqual(allUsersInStore(), [.john])
  }

  func testSaveOptional() throws {
    let store = createFreshUsersStore()

    try store.save(nil)
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(allUsersInStore().isEmpty)

    try store.save(.john)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.john])
    XCTAssertEqual(allUsersInStore(), [.john])
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
    let users: Set<User> = [.john, .johnson, .james]

    try store.save(Array(users))
    XCTAssertEqual(store.objectsCount, 3)
    XCTAssertEqual(Set(store.allObjects()), users)
    XCTAssertEqual(allUsersInStore(), users)
  }

  func testSaveInvalidObjects() {
    let store = createFreshUsersStore()

    XCTAssertThrowsError(try store.save([.james, .john, .invalid]))
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssertEqual(store.allObjects(), [])
    XCTAssert(allUsersInStore().isEmpty)
  }

  func testObject() throws {
    let store = createFreshUsersStore()

    try store.save(.johnson)
    XCTAssertEqual(store.object(withId: User.johnson.id), .johnson)
    XCTAssertEqual(allUsersInStore(), [.johnson])

    XCTAssertNil(store.object(withId: 123))
    XCTAssertEqual(allUsersInStore(), [.johnson])
  }

  func testObjects() throws {
    let store = createFreshUsersStore()
    try store.save([.john, .james])
    XCTAssertEqual(store.objects(withIds: [User.john.id, User.james.id, 5]), [.john, .james])
    XCTAssertEqual(allUsersInStore(), [.john, .james])
  }

  func testAllObjects() throws {
    let store = createFreshUsersStore()

    try store.save(.john)
    XCTAssertEqual(Set(store.allObjects()), [.john])
    XCTAssertEqual(allUsersInStore(), [.john])

    try store.save(.johnson)
    XCTAssertEqual(Set(store.allObjects()), [.john, .johnson])
    XCTAssertEqual(allUsersInStore(), [.john, .johnson])

    try store.save(.james)
    XCTAssertEqual(Set(store.allObjects()), [.john, .johnson, .james])
    XCTAssertEqual(allUsersInStore(), [.john, .johnson, .james])
  }

  func testRemoveObject() throws {
    let store = createFreshUsersStore()

    try store.save(.james)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.james])
    XCTAssertEqual(allUsersInStore(), [.james])

    store.remove(withId: 123)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.james])
    XCTAssertEqual(allUsersInStore(), [.james])

    store.remove(withId: User.james.id)
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
    XCTAssert(allUsersInStore().isEmpty)
  }

  func testRemoveObjects() throws {
    let store = createFreshUsersStore()
    try store.save(.james)
    try store.save(.johnson)
    XCTAssertEqual(store.objectsCount, 2)
    XCTAssertEqual(Set(store.allObjects()), [.james, .johnson])

    store.remove(withIds: [User.james.id, 5, 6, 8])
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.johnson])
    XCTAssertEqual(allUsersInStore(), [.johnson])
  }

  func testRemoveAll() throws {
    let store = createFreshUsersStore()
    try store.save(.john)
    try store.save(.johnson)
    try store.save(.james)

    store.removeAll()
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
    XCTAssert(allUsersInStore().isEmpty)
  }

  func testContainsObject() throws {
    let store = createFreshUsersStore()
    XCTAssertFalse(store.containsObject(withId: 10))

    try store.save(.john)
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
    XCTAssertEqual(count(), users.count)
  }

  func testThreadSafety() {
    let store = createFreshUsersStore()
    let expectation1 = XCTestExpectation(description: "Store has 1000 items.")
    for i in 0..<1_000 {
      Thread.detachNewThread {
        let user = User(id: i, firstName: "", lastName: "", age: .random(in: 1..<90))
        try? store.save(user)
      }
    }
    Thread.sleep(forTimeInterval: 2)
    if store.objectsCount == 1_000 && allUsersInStore().count == 1_000 {
      expectation1.fulfill()
    }

    let expectation2 = XCTestExpectation(description: "Store has 500 items.")
    for i in 0..<500 {
      Thread.detachNewThread {
        store.remove(withId: i)
      }
    }
    Thread.sleep(forTimeInterval: 2)
    if store.objectsCount == 500 && allUsersInStore().count == 500 {
      expectation2.fulfill()
    }

    wait(for: [expectation1, expectation2], timeout: 5)
  }
}

// MARK: - Helpers

private extension MultiUserDefaultsStoreTests {
  func createFreshUsersStore(identifier: String = "users") -> MultiUserDefaultsStore<User> {
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
    return UserDefaults(suiteName: identifier)?.integer(forKey: "\(identifier)-count") ?? 0
  }
}
