@testable import UserDefaultsStore
@testable import TestUtils

import Foundation
import XCTest

final class SingleUserDefaultsStoreTests: XCTestCase {
  func testCreateStore() {
    let identifier = UUID().uuidString
    let store = createFreshUserStore(identifier: identifier)
    XCTAssertEqual(store.identifier, identifier)
  }

  func testSaveObject() throws {
    let store = createFreshUserStore()
    try store.save(.ahmad)
    XCTAssertEqual(store.object(), .ahmad)
    XCTAssertEqual(userInStore(), .ahmad)

    let user: User? = .kareem
    try store.save(user)
    XCTAssertEqual(store.object(), .kareem)
    XCTAssertEqual(userInStore(), .kareem)

    try store.save(nil)
    XCTAssertNil(store.object())
    XCTAssertNil(userInStore())
  }

  func testSaveInvalidObject() {
    let store = createFreshUserStore()
    XCTAssertThrowsError(try store.save(User.invalid))
    XCTAssertNil(userInStore())
  }

  func testObject() throws {
    let store = createFreshUserStore()
    XCTAssertNoThrow(try store.save(.dalia))
    XCTAssertEqual(store.object(), .dalia)
    XCTAssertEqual(userInStore(), .dalia)
  }

  func testRemove() {
    let store = createFreshUserStore()
    XCTAssertNoThrow(try store.save(.dalia))
    XCTAssertEqual(store.object(), .dalia)

    store.remove()
    XCTAssertNil(store.object())
    XCTAssertNil(userInStore())
  }
}

// MARK: - Helpers

private extension SingleUserDefaultsStoreTests {
  func createFreshUserStore(
    identifier: String = "user"
  ) -> SingleUserDefaultsStore<User> {
    let store = SingleUserDefaultsStore<User>(identifier: identifier)
    store.remove()
    return store
  }

  func userInStore(identifier: String = "user") -> User? {
    guard let data = UserDefaults(suiteName: identifier)?
      .data(forKey: "object") else { return nil }
    return try? JSONDecoder().decode(User.self, from: data)
  }
}
