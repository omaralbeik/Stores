@testable import Blueprints
@testable import TestUtils

import Foundation
import XCTest

final class AnySingleObjectStoreTests: XCTestCase {
  func testSave() throws {
    let stores = createFreshUserStores()
    try stores.anyStore.save(.ahmad)
    XCTAssertEqual(stores.fakeStore.underlyingObject, .ahmad)
  }

  func testSaveOptional() throws {
    let stores = createFreshUserStores()
    try stores.anyStore.save(nil)
    XCTAssertNil(stores.fakeStore.underlyingObject)
  }

  func testObject() throws {
    let stores = createFreshUserStores()
    try stores.fakeStore.save(.dalia)
    XCTAssertEqual(stores.anyStore.object(), .dalia)
  }

  func testRemove() throws {
    let stores = createFreshUserStores()
    try stores.anyStore.save(.dalia)
    try stores.anyStore.remove()
    XCTAssertNil(stores.fakeStore.underlyingObject)
  }
}

// MARK: - Helpers

private extension AnySingleObjectStoreTests {
  typealias Stores = (
    fakeStore: SingleObjectStoreFake<User>,
    anyStore: AnySingleObjectStore<User>
  )

  func createFreshUserStores() -> Stores {
    let fakeStore = SingleObjectStoreFake<User>()
    let anyStore = fakeStore.eraseToAnyStore()
    return (fakeStore, anyStore)
  }
}
