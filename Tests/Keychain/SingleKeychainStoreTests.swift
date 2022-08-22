#if canImport(Security)

@testable import TestUtils
@testable import KeychainStore

import Foundation
import XCTest

final class SingleKeychainStoreTests: XCTestCase {
  private var store: SingleKeychainStore<User>?

  override func tearDownWithError() throws {
    try store?.remove()
  }

  func testCreateStore() {
    let identifier = UUID().uuidString
    let accessibility = KeychainAccessibility.afterFirstUnlock
    let store = createFreshUserStore(
      identifier: identifier,
      accessibility: accessibility
    )
    XCTAssertEqual(store.identifier, identifier)
    XCTAssertEqual(store.accessibility, accessibility)
    XCTAssertEqual(
      store.serviceName(),
      "com.omaralbeik.stores.single.\(identifier)"
    )
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
  }

  func testObject() throws {
    let store = createFreshUserStore()
    XCTAssertNoThrow(try store.save(.dalia))
    XCTAssertEqual(store.object(), .dalia)
  }

  func testRemove() throws {
    let store = createFreshUserStore()
    XCTAssertNoThrow(try store.save(.dalia))
    XCTAssertEqual(store.object(), .dalia)

    try store.remove()
    XCTAssertNil(store.object())
  }
}

// MARK: - Helpers

private extension SingleKeychainStoreTests {
  func createFreshUserStore(
    identifier: String = "user",
    accessibility: KeychainAccessibility = .whenUnlockedThisDeviceOnly
  ) -> SingleKeychainStore<User> {
    let store = SingleKeychainStore<User>.init(
      identifier: identifier,
      accessibility: accessibility
    )
    XCTAssertNoThrow(try store.remove())
    self.store = store
    return store
  }
}

#endif
