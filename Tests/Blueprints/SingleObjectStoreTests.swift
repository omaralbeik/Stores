@testable import Blueprints
@testable import TestUtils

import Foundation
import XCTest

final class SingleObjectStoreTests: XCTestCase {
  func testSaveOptionalObject() throws {
    let store = createFreshUserStore()
    let user: User? = .john

    try store.save(user)
    XCTAssertEqual(store.object(), .john)
    XCTAssertEqual(store.underlyingObject, .john)

    try store.save(nil)
    XCTAssertNil(store.object())
    XCTAssertNil(store.underlyingObject)
  }
}

// MARK: - Helpers

private extension SingleObjectStoreTests {
  func createFreshUserStore() -> SingleObjectStoreFake<User> {
    return .init()
  }
}
