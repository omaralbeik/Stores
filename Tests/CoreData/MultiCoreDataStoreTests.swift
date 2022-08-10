@testable import CoreDataStore
@testable import TestUtils

import Foundation
import CoreData
import XCTest

final class MultiCoreDataStoreTests: XCTestCase {
  func testSaveObject() throws {
    let store = createFreshUsersStore()

    try store.save(.john)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.john])
  }

  func testSaveOptional() throws {
    let store = createFreshUsersStore()

    try store.save(nil)
    XCTAssertEqual(store.objectsCount, 0)

    try store.save(.john)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.john])
  }

  func testSaveInvalidObject() {
    let store = createFreshUsersStore()
    let optionalUser: User? = .invalid

    XCTAssertThrowsError(try store.save(.invalid))
    XCTAssertThrowsError(try store.save(optionalUser))
    XCTAssert(store.allObjects().isEmpty)
  }

  func testSaveObjects() throws {
    let store = createFreshUsersStore()
    let users: [User] = [.john, .johnson, .james]

    try store.save(users)
    XCTAssertEqual(store.objectsCount, 3)
    XCTAssertEqual(store.allObjects(), users)
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
    XCTAssertEqual(store.object(withId: User.johnson.id), .johnson)

    XCTAssertNil(store.object(withId: 123))
  }

  func testObjects() {
    let store = createFreshUsersStore()
    XCTAssertNoThrow(try store.save([.john, .james]))
    XCTAssertEqual(store.objects(withIds: [User.john.id, User.james.id, 5]), [.john, .james])
  }

  func testAllObjects() {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(.john))
    XCTAssertEqual(store.allObjects(), [.john])

    XCTAssertNoThrow(try store.save(.johnson))
    XCTAssertEqual(store.allObjects(), [.john, .johnson])

    XCTAssertNoThrow(try store.save(.james))
    XCTAssertEqual(store.allObjects(), [.john, .johnson, .james])
  }

  func testRemoveObject() throws {
    let store = createFreshUsersStore()

    XCTAssertNoThrow(try store.save(.james))
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.james])

    try store.remove(withId: 123)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.james])

    try store.remove(withId: User.james.id)
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
  }

  func testRemoveObjects() throws {
    let store = createFreshUsersStore()
    try store.save(.james)
    try store.save(.johnson)
    XCTAssertEqual(store.objectsCount, 2)

    try store.remove(withIds: [User.james.id, 5, 6, 8])
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.johnson])
  }

  func testRemoveAll() throws {
    let store = createFreshUsersStore()
    try store.save(.john)
    try store.save(.johnson)
    try store.save(.james)

    try store.removeAll()
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
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
        try? store.remove(withId: i)
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

private extension MultiCoreDataStoreTests {
  func createFreshUsersStore(databaseName: String = "users") -> MultiCoreDataStore<User> {
    let store = MultiCoreDataStore<User>(databaseName: databaseName)
    XCTAssertNoThrow(try store.removeAll())
    return store
  }
}
