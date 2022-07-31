@testable import UserDefaultsStore

import Foundation
import TestUtils
import XCTest

final class MultiUserDefaultsStoreTests: XCTestCase {
  func testCreateStore() {
    let uniqueIdentifier = UUID().uuidString
    let store = MultiUserDefaultsStore<User>(uniqueIdentifier: uniqueIdentifier)
    XCTAssertEqual(store.uniqueIdentifier, uniqueIdentifier)
  }

  func testSaveObject() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(User.john))
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [User.john])
  }

  func testSaveOptional() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(nil))
    XCTAssertEqual(store.objectsCount, 0)

    XCTAssertNoThrow(try store.save(User.john))
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [User.john])
  }

  func testSaveInvalidObject() {
    let store = createFreshUsersStore()

    let optionalUser: User? = .invalid
    XCTAssertThrowsError(try store.save(.invalid))
    XCTAssertThrowsError(try store.save(optionalUser))
  }

  func testSaveObjects() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save([.john, .johnson, .james]))
    XCTAssertEqual(store.objectsCount, 3)
    XCTAssert(store.allObjects().contains(.john))
    XCTAssert(store.allObjects().contains(.johnson))
    XCTAssert(store.allObjects().contains(.james))
  }

  func testSaveInvalidObjects() {
    let store = createFreshUsersStore()

    XCTAssertThrowsError(try store.save([.james, .john, .invalid]))
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssertEqual(store.allObjects(), [])
  }

  func testObject() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(.johnson))
    let user = store.object(withId: 2)
    XCTAssertNotNil(user)

    let invalidUser = store.object(withId: 123)
    XCTAssertNil(invalidUser)
  }

  func testObjects() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(.james))
    XCTAssertNoThrow(try store.save(.johnson))

    let users = store.objects(withIds: [User.james.id, User.johnson.id, 5])
    XCTAssertEqual(users.count, 2)
    XCTAssert(users.contains(.james))
    XCTAssert(users.contains(.johnson))
  }

  func testAllObjects() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(.john))
    XCTAssertEqual(Set(store.allObjects()), [.john])

    XCTAssertNoThrow(try store.save(.johnson))
    XCTAssertEqual(Set(store.allObjects()), [.john, .johnson])

    XCTAssertNoThrow(try store.save(.james))
    XCTAssertEqual(Set(store.allObjects()), [.john, .johnson, .james])
  }

  func testRemoveObject() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(.james))

    XCTAssertEqual(store.objectsCount, 1)

    store.remove(withId: 3)
    XCTAssertEqual(store.objectsCount, 0)
  }

  func testRemoveObjects() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(.james))
    XCTAssertNoThrow(try store.save(.johnson))

    XCTAssertEqual(store.objectsCount, 2)

    store.remove(withIds: [User.james.id, 5, 6, 8])
    XCTAssertEqual(store.objectsCount, 1)
  }

  func testRemoveAll() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(.john))
    XCTAssertNoThrow(try store.save(.johnson))
    XCTAssertNoThrow(try store.save(.james))

    store.removeAll()
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
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
    if store.objectsCount == 1_000 {
      expectation1.fulfill()
    }

    let expectation2 = XCTestExpectation(description: "Store has 500 items.")
    for i in 0..<500 {
      Thread.detachNewThread {
        store.remove(withId: i)
      }
    }
    Thread.sleep(forTimeInterval: 2)
    if store.objectsCount == 500 {
      expectation2.fulfill()
    }

    wait(for: [expectation1, expectation2], timeout: 5)
  }
}

// MARK: - Helpers

private extension MultiUserDefaultsStoreTests {
  func createFreshUsersStore(uniqueIdentifier: String = "users") -> MultiUserDefaultsStore<User> {
    let store = MultiUserDefaultsStore<User>(uniqueIdentifier: uniqueIdentifier)
    store.removeAll()
    return store
  }
}
