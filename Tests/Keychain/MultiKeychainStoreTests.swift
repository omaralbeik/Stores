@testable import TestUtils
@testable import KeychainStore

import Foundation
import XCTest

final class MultiKeychainStoreTests: XCTestCase {
  private var store: MultiKeychainStore<User>?

  override func tearDownWithError() throws {
    try store?.removeAll()
  }

  func testCreateStore() throws {
    let identifier = UUID().uuidString
    let accessibility = KeychainAccessibility.afterFirstUnlock
    let store = createFreshUsersStore(
      identifier: identifier,
      accessibility: accessibility
    )
    XCTAssertEqual(store.identifier, identifier)
    XCTAssertEqual(store.accessibility, accessibility)
    XCTAssertEqual(
      store.serviceName(),
      "com.omaralbeik.stores.multi.\(identifier)"
    )
  }

  func testSaveObject() throws {
    let store = createFreshUsersStore()

    try store.save(.ahmad)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.ahmad])
  }

  func testSaveOptional() throws {
    let store = createFreshUsersStore()

    try store.save(nil)
    XCTAssertEqual(store.objectsCount, 0)

    try store.save(.ahmad)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.ahmad])
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
    let users: Set<User> = [.ahmad, .dalia, .kareem]

    try store.save(Array(users))
    XCTAssertEqual(store.objectsCount, 3)
    XCTAssertEqual(Set(store.allObjects()), users)

    try store.removeAll()
  }

  func testSaveInvalidObjects() {
    let store = createFreshUsersStore()

    XCTAssertThrowsError(try store.save([.kareem, .ahmad, .invalid]))
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssertEqual(store.allObjects(), [])
  }

  func testObject() throws {
    let store = createFreshUsersStore()

    try store.save(.dalia)
    XCTAssertEqual(store.object(withId: User.dalia.id), .dalia)

    XCTAssertNil(store.object(withId: 123))
  }

  func testObjects() throws {
    let store = createFreshUsersStore()
    try store.save([.ahmad, .kareem])
    XCTAssertEqual(
      store.objects(withIds: [User.ahmad.id, User.kareem.id, 5]),
      [.ahmad, .kareem]
    )
  }

  func testAllObjects() throws {
    let store = createFreshUsersStore()

    try store.save(.ahmad)
    XCTAssertEqual(Set(store.allObjects()), [.ahmad])

    try store.save(.dalia)
    XCTAssertEqual(Set(store.allObjects()), [.ahmad, .dalia])

    try store.save(.kareem)
    XCTAssertEqual(Set(store.allObjects()), [.ahmad, .dalia, .kareem])
  }

  func testRemoveObject() throws {
    let store = createFreshUsersStore()

    try store.save(.kareem)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.kareem])

    try store.remove(withId: 123)
    XCTAssertEqual(store.objectsCount, 1)
    XCTAssertEqual(store.allObjects(), [.kareem])

    try store.remove(withId: User.kareem.id)
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
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
  }

  func testRemoveAll() throws {
    let store = createFreshUsersStore()
    try store.save(.ahmad)
    try store.save(.dalia)
    try store.save(.kareem)

    try store.removeAll()
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.allObjects().isEmpty)
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
    for i in 0 ..< 10 {
      user.firstName = "\(i)"
      try store.save(user)
    }

    XCTAssertEqual(store.objectsCount, users.count)
  }

  func testThreadSafety() {
    let store = createFreshUsersStore()
    let expectation1 = XCTestExpectation(description: "Store has 200 items.")
    for i in 0 ..< 200 {
      Thread.detachNewThread {
        let user = User(
          id: i,
          firstName: "",
          lastName: "",
          age: .random(in: 1 ..< 90)
        )
        try! store.save(user)
      }
    }
    Thread.sleep(forTimeInterval: 4)
    if store.objectsCount == 200 {
      expectation1.fulfill()
    }

    let expectation2 = XCTestExpectation(description: "Store has 100 items.")
    for i in 0 ..< 100 {
      Thread.detachNewThread {
        try! store.remove(withId: i)
      }
    }
    Thread.sleep(forTimeInterval: 4)
    if store.objectsCount == 100 {
      expectation2.fulfill()
    }

    wait(for: [expectation1, expectation2], timeout: 10)
  }
}

// MARK: - Helpers

private extension MultiKeychainStoreTests {
  func createFreshUsersStore(
    identifier: String = "users",
    accessibility: KeychainAccessibility = .whenUnlockedThisDeviceOnly
  ) -> MultiKeychainStore<User> {
    let store = MultiKeychainStore<User>.init(
      identifier: identifier,
      accessibility: accessibility
    )
    XCTAssertNoThrow(try store.removeAll())
    self.store = store
    return store
  }
}
