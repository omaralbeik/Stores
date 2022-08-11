@testable import CoreDataStore
@testable import TestUtils

import Foundation
import CoreData
import XCTest

final class SingleCoreDataStoreTests: XCTestCase {
  func testCreateStore() {
    let databaseName = UUID().uuidString
    let store = createFreshUserStore(databaseName: databaseName)
    XCTAssertEqual(store.databaseName, databaseName)
  }

  func testSaveObject() throws {
    let store = createFreshUserStore()
    try store.save(.ahmad)
    XCTAssertEqual(store.object(), .ahmad)

    let user: User? = .kareem
    try store.save(user)
    XCTAssertEqual(store.object(), .kareem)

    try store.save(nil)
    XCTAssertNil(store.object())
  }

  func testSaveInvalidObject() {
    let store = createFreshUserStore()
    XCTAssertThrowsError(try store.save(User.invalid))
    XCTAssertNil(store.object())
  }

  func testObject() throws {
    let store = createFreshUserStore()
    try store.save(.dalia)
    XCTAssertEqual(store.object(), .dalia)
  }
}

// MARK: - Helpers

private extension SingleCoreDataStoreTests {
  func createFreshUserStore(
    databaseName: String = "user"
  ) -> SingleCoreDataStore<User> {
    let store = SingleCoreDataStore<User>(databaseName: databaseName)
    store.logger.printEnabled = false
    XCTAssertNoThrow(try store.remove())
    return store
  }
}
