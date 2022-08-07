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
    try store.save(.john)
    XCTAssertEqual(store.object(), .john)

    let user: User? = .james
    try store.save(user)
    XCTAssertEqual(store.object(), .james)

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
    try store.save(.johnson)
    XCTAssertEqual(store.object(), .johnson)
  }
}

// MARK: - Helpers

private extension SingleCoreDataStoreTests {
  func createFreshUserStore(databaseName: String = "user") -> SingleCoreDataStore<User> {
    let store = SingleCoreDataStore<User>(databaseName: databaseName)
    XCTAssertNoThrow(try store.remove())
    return store
  }
}
