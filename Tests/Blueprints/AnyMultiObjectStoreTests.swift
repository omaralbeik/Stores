@testable import Blueprints
@testable import TestUtils

import Foundation
import XCTest

final class AnyMultiObjectStoreTests: XCTestCase {
  func testSave() throws {
    let stores = createFreshUsersStores()
    try stores.anyStore.save(.ahmad)
    XCTAssertEqual(stores.fakeStore.dictionary, [User.ahmad.id: .ahmad])
  }

  func testSaveOptional() throws {
    let stores = createFreshUsersStores()
    try stores.anyStore.save(nil)
    XCTAssert(stores.fakeStore.dictionary.isEmpty)
  }

  func testSaveObjects() throws {
    let stores = createFreshUsersStores()
    try stores.anyStore.save([.ahmad, .dalia])
    XCTAssertEqual(
      stores.fakeStore.dictionary,
      [User.ahmad.id: .ahmad, User.dalia.id: .dalia]
    )
  }

  func testObjectsCount() throws {
    let stores = createFreshUsersStores()
    try stores.fakeStore.save(.dalia)
    XCTAssertEqual(stores.anyStore.objectsCount, 1)
  }

  func testContainsObject() throws {
    let stores = createFreshUsersStores()
    try stores.fakeStore.save(.dalia)
    XCTAssert(stores.anyStore.containsObject(withId: User.dalia.id))
    XCTAssertFalse(stores.anyStore.containsObject(withId: User.ahmad.id))
  }

  func testObject() throws {
    let stores = createFreshUsersStores()
    try stores.fakeStore.save(.dalia)
    XCTAssertEqual(stores.anyStore.object(withId: User.dalia.id), .dalia)
    XCTAssertNil(stores.anyStore.object(withId: User.ahmad.id))
  }

  func testObjects() throws {
    let stores = createFreshUsersStores()
    try stores.fakeStore.save(.dalia)
    XCTAssertEqual(
      stores.anyStore.objects(withIds: [User.dalia.id]),
      [.dalia]
    )
    XCTAssert(stores.anyStore.objects(withIds: [User.ahmad.id]).isEmpty)
  }

  func testAllObject() throws {
    let stores = createFreshUsersStores()
    try stores.fakeStore.save([.dalia, .kareem])
    XCTAssertEqual(Set(stores.anyStore.allObjects()), [.dalia, .kareem])
  }

  func testRemove() throws {
    let stores = createFreshUsersStores()
    try stores.fakeStore.save([.ahmad, .dalia, .kareem])
    try stores.anyStore.remove(withId: User.kareem.id)
    XCTAssertEqual(
      stores.fakeStore.dictionary,
      [User.ahmad.id: .ahmad, User.dalia.id: .dalia]
    )

    try stores.anyStore.remove(withIds: [User.ahmad.id, User.dalia.id])
    XCTAssert(stores.fakeStore.dictionary.isEmpty)
  }

  func testRemoveAll() throws {
    let stores = createFreshUsersStores()
    try stores.fakeStore.save([.dalia, .kareem])
    try stores.anyStore.removeAll()
    XCTAssert(stores.fakeStore.dictionary.isEmpty)
  }
}

// MARK: - Helpers

private extension AnyMultiObjectStoreTests {
  typealias Stores = (
    fakeStore: MultiObjectStoreFake<User>,
    anyStore: AnyMultiObjectStore<User>
  )

  func createFreshUsersStores() -> Stores {
    let fakeStore = MultiObjectStoreFake<User>()
    let anyStore = fakeStore.eraseToAnyStore()
    XCTAssert(anyStore.eraseToAnyStore() === anyStore)
    return (fakeStore, anyStore)
  }
}
