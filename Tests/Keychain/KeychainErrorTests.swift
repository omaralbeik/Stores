#if canImport(Security)

@testable import KeychainStore

import Foundation
import XCTest

final class KeychainErrorTests: XCTestCase {
  func testErrorDescription() {
    XCTAssertEqual(
      KeychainError.invalidResult.errorDescription,
      "Keychain Error: Invalid result."
    )

    XCTAssertEqual(
      KeychainError.keychain(0).errorDescription,
      "Keychain Error: OSStatus=0."
    )
  }
}

#endif
