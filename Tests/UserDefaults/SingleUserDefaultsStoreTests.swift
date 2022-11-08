@testable import TestUtils
@testable import UserDefaultsStore

import Foundation
import XCTest

final class SingleUserDefaultsStoreTests: XCTestCase {
  private var store: SingleUserDefaultsStore<User>?

  override func tearDown() {
    store?.remove()
  }

  func testCreateStore() {
    let suiteName = UUID().uuidString
    let store = createFreshUserStore(suiteName: suiteName)
    XCTAssertEqual(store.suiteName, suiteName)
  }

  func testDeprecatedCreateStore() {
    let identifier = UUID().uuidString
    let store = SingleUserDefaultsStore<User>(identifier: identifier)
    XCTAssertEqual(identifier, store.identifier)
    self.store = store
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
    suiteName: String = "user"
  ) -> SingleUserDefaultsStore<User> {
    let store = SingleUserDefaultsStore<User>(suiteName: suiteName)
    XCTAssertEqual(suiteName, store.identifier)
    store.remove()
    self.store = store
    return store
  }

  func userInStore(identifier: String = "user") -> User? {
    guard let data = UserDefaults(suiteName: identifier)?
      .data(forKey: "object") else { return nil }
    return try? JSONDecoder().decode(User.self, from: data)
  }
}
