@testable import Blueprints
@testable import TestUtils

import Foundation
import XCTest

final class SingleObjectStoreTests: XCTestCase {
  func testSaveOptionalObject() throws {
    let store = createFreshUserStore()
    let user: User? = .ahmad

    try store.save(user)
    XCTAssertEqual(store.object(), .ahmad)
    XCTAssertEqual(store.underlyingObject, .ahmad)

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
