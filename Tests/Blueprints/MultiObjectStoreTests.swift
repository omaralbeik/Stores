@testable import Blueprints
@testable import TestUtils

import Foundation
import XCTest

final class MultiObjectStoreTests: XCTestCase {
  func testSaveOptionalObject() throws {
    let store = createFreshUsersStore()
    let user: User? = .ahmad
    try store.save(user)
    try store.save(nil)
    XCTAssertEqual(store.allObjects(), [.ahmad])
    XCTAssertEqual(store.dictionary, [User.ahmad.id: .ahmad])
  }

  func testSaveObjects() throws {
    let store = createFreshUsersStore()
    try store.save([.ahmad, .dalia])
    XCTAssertEqual(Set(store.allObjects()), [.ahmad, .dalia])
    XCTAssertEqual(store.dictionary, [
      User.ahmad.id: .ahmad,
      User.dalia.id: .dalia,
    ])
  }

  func testSaveObjectsSet() throws {
    let store = createFreshUsersStore()
    let users: Set<User> = [.ahmad, .dalia]
    try store.save(users)
    XCTAssertEqual(Set(store.allObjects()), users)
    XCTAssertEqual(store.dictionary, [
      User.ahmad.id: .ahmad,
      User.dalia.id: .dalia,
    ])
  }

  func testObjects() throws {
    let store = createFreshUsersStore()
    try store.save([.ahmad, .dalia])
    let users = store.objects(withIds: [User.ahmad.id, User.invalid.id])
    XCTAssertEqual(users, [.ahmad])
  }

  func testRemoveObjects() throws {
    let store = createFreshUsersStore()
    try store.save(.ahmad)
    try store.remove(withIds: [User.ahmad.id, User.dalia.id])
    XCTAssertEqual(store.objectsCount, 0)
    XCTAssert(store.dictionary.isEmpty)
  }
}

// MARK: - Helpers

private extension MultiObjectStoreTests {
  func createFreshUsersStore() -> MultiObjectStoreFake<User> {
    return .init()
  }
}
