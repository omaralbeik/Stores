@testable import TestUtils
@testable import KeychainStore

import Foundation
import XCTest

final class SingleKeychainStoreTests: XCTestCase {
  func testCreateStore() {
    let serviceName = "test"
    let account = UUID().uuidString
    let accessibility = KeychainAccessibility.afterFirstUnlock
    let store = createFreshUserStore(
      serviceName: serviceName,
      account: account,
      accessibility: accessibility
    )
    XCTAssertEqual(store.serviceName, serviceName)
    XCTAssertEqual(store.account, account)
    XCTAssertEqual(store.accessibility, accessibility)
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
    serviceName: String = "com.omaralbeik.stores",
    account: String = "user",
    accessibility: KeychainAccessibility = .whenUnlockedThisDeviceOnly
  ) -> SingleKeychainStore<User> {
    let store = SingleKeychainStore<User>.init(
      serviceName: serviceName,
      account: account,
      accessibility: accessibility
    )
    XCTAssertNoThrow(try store.remove())
    return store
  }
}
