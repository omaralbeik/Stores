@testable import UserDefaultsStore
@testable import TestUtils

import Foundation
import XCTest

final class SingleUserDefaultsStoreTests: XCTestCase {
  func testCreateStore() {
    let identifier = UUID().uuidString
    let store = createFreshUserStore(identifier: identifier)
    XCTAssertEqual(store.uniqueIdentifier, identifier)
  }

  func testSaveObject() throws {
    let store = createFreshUserStore()
    XCTAssertNoThrow(try store.save(.john))
    XCTAssertEqual(store.object(), .john)
    XCTAssertEqual(userInStore(), .john)
  }

  func testSaveInvalidObject() {
    let store = createFreshUserStore()
    XCTAssertThrowsError(try store.save(User.invalid))
    XCTAssertNil(userInStore())
  }

  func testObject() throws {
    let store = createFreshUserStore()
    XCTAssertNoThrow(try store.save(.johnson))
    XCTAssertEqual(store.object(), .johnson)
    XCTAssertEqual(userInStore(), .johnson)
  }

  func testRemove() {
    let store = createFreshUserStore()
    XCTAssertNoThrow(try store.save(.johnson))
    XCTAssertEqual(store.object(), .johnson)

    store.remove()
    XCTAssertNil(store.object())
    XCTAssertNil(userInStore())
  }
}

// MARK: - Helpers

private extension SingleUserDefaultsStoreTests {
  func createFreshUserStore(identifier: String = "user") -> SingleUserDefaultsStore<User> {
    let store = SingleUserDefaultsStore<User>(uniqueIdentifier: identifier)
    store.remove()
    return store
  }

  func userInStore(identifier: String = "user") -> User? {
    guard let data = UserDefaults(suiteName: identifier)?.data(forKey: "object") else { return nil }
    return try? JSONDecoder().decode(User.self, from: data)
  }
}
