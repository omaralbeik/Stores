#if canImport(Security)

import Security

enum KeychainError: Error {
  case keychain(OSStatus)
  case invalidResult
}

#endif
