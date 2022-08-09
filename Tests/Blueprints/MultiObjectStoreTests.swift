@testable import Blueprints
@testable import TestUtils

import Foundation
import XCTest

final class MultiObjectStoreTests: XCTestCase {
  func testSaveOptionalObject() throws {
    let store = createFreshUsersStore()
    let user: User? = .john
    try store.save(user)
    try store.save(nil)
    XCTAssertEqual(store.allObjects(), [.john])
    XCTAssertEqual(store.dictionary, [User.john.id: .john])
  }

  func testSaveObjects() throws {
    let store = createFreshUsersStore()
    try store.save([.john, .johnson])
    XCTAssertEqual(Set(store.allObjects()), [.john, .johnson])
    XCTAssertEqual(store.dictionary, [
      User.john.id: .john,
      User.johnson.id: .johnson
    ])
  }

  func testSaveObjectsSet() throws {
    let store = createFreshUsersStore()
    let users: Set<User> = [.john, .johnson]
    try store.save(users)
    XCTAssertEqual(Set(store.allObjects()), users)
    XCTAssertEqual(store.dictionary, [
      User.john.id: .john,
      User.johnson.id: .johnson
    ])
  }

  func testObjects() throws {
    let store = createFreshUsersStore()
    try store.save([.john, .johnson])
    let users = store.objects(withIds: [User.john.id, User.invalid.id])
    XCTAssertEqual(users, [.john])
  }

  func testRemoveObjects() throws {
    let store = createFreshUsersStore()
    try store.save(.john)
    try store.remove(withIds: [User.john.id, User.johnson.id])
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
