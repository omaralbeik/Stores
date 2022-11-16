#if canImport(Security)

import Security
import Foundation

enum KeychainError: LocalizedError {
  case keychain(OSStatus)
  case invalidResult

  var errorDescription: String? {
    switch self {
    case .keychain(let oSStatus):
      return "Keychain Error: OSStatus=\(oSStatus)."
    case .invalidResult:
      return "Keychain Error: Invalid result."
    }
  }
}

#endif
