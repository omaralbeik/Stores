@testable import UserDefaultsStore

import Foundation
import TestUtils
import XCTest

final class SingleUserDefaultsStoreTests: XCTestCase {
  func testCreateStore() {
    let uniqueIdentifier = UUID().uuidString
    let store = createFreshUserStore(uniqueIdentifier: uniqueIdentifier)
    XCTAssertEqual(store.uniqueIdentifier, uniqueIdentifier)
  }

  func testSaveObject() {
    let store = createFreshUserStore()

    XCTAssertNoThrow(try store.save(User.john))
    XCTAssertNotNil(store.object)
    XCTAssertEqual(store.object(), User.john)
  }

  func testSaveInvalidObject() {
    let store = createFreshUserStore()
    XCTAssertThrowsError(try store.save(User.invalid))
  }

  func testObject() {
    let store = createFreshUserStore()

    XCTAssertNoThrow(try store.save(User.johnson))
    XCTAssertNotNil(store.object())
  }
}

// MARK: - Helpers

private extension SingleUserDefaultsStoreTests {
  func createFreshUserStore(uniqueIdentifier: String = "single-user") -> SingleUserDefaultsStore<User> {
    let store = SingleUserDefaultsStore<User>(uniqueIdentifier: uniqueIdentifier)
    store.remove()
    return store
  }
}
