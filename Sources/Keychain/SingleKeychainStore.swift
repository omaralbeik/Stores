import Blueprints
import Foundation
import Security

/// The single Keychain object store offers a convenient and type-safe way to store and retrieve a single
/// `Codable` object to the keychain.
///
/// > Thread safety: This is a thread-safe class.
public final class SingleKeychainStore<Object: Codable>: SingleObjectStore {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let lock = NSRecursiveLock()

  /// Used for the `kSecAttrService` property to uniquely identify this keychain accessor.
  ///
  /// > Note: This can be your app's bundle identifier.
  public let serviceName: String

  /// Store's account name.
  ///
  /// > Note: This is used for the `kSecAttrAccount` property to uniquely identify this keychain accessor.
  public let account: String

  /// Store's accessibility level.
  public let accessibility: KeychainAccessibility

  /// Initialize store.
  /// - Parameters:
  ///   - serviceName: used for the `kSecAttrService` property to uniquely identify this keychain
  ///   accessor. This can be your app's bundle identifier.
  ///   - account: used for the `kSecAttrAccount` property to uniquely identify this keychain
  ///   accessor.
  ///   - accessibility: store's accessibility level. Defaults to `.whenUnlockedThisDeviceOnly`
  ///
  /// > Note: Creating a store is a fairly cheap operation, you can create multiple instances of the same store
  /// with same parameters.
  required public init(
    serviceName: String,
    account: String,
    accessibility: KeychainAccessibility = .whenUnlockedThisDeviceOnly
  ) {
    self.serviceName = serviceName
    self.account = account
    self.accessibility = accessibility
  }

  // MARK: - SingleObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any encoding errors.
  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(object)
      try addOrUpdate(data)
    }
  }

  /// Returns the object saved in the store
  /// - Returns: object saved in the store. `nil` if no object is saved in store.
  public func object() -> Object? {
    let query = generateQuery {
      $0[kSecReturnData] = kCFBooleanTrue
      $0[kSecMatchLimit] = kSecMatchLimitOne
    }
    var result: AnyObject?
    SecItemCopyMatching(query as CFDictionary, &result)
    guard let data = result as? Data else { return nil }
    return try? decoder.decode(Object.self, from: data)
  }

  /// Removes any saved object in the store.
  public func remove() throws {
    try sync {
      let query = generateQuery()
      let status = SecItemDelete(query as CFDictionary)
      switch status {
      case errSecSuccess, errSecItemNotFound:
        return
      default:
        throw KeychainError(status: status)
      }
    }
  }
}

// MARK: - Helpers

extension SingleKeychainStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    try action()
    lock.unlock()
  }

  typealias Query = Dictionary<CFString, Any>

  func addOrUpdate(_ data: Data) throws {
    let query = generateQuery { $0[kSecValueData] = data }
    let status = SecItemAdd(query as CFDictionary, nil)
    switch status {
    case errSecSuccess:
      return
    case errSecDuplicateItem:
      try update(data)
    default:
      throw KeychainError(status: status)
    }
  }

  func update(_ data: Data) throws {
    let query = generateQuery { $0[kSecValueData] = data }
    let status = SecItemUpdate(
      query as CFDictionary,
      query as CFDictionary
    )
    switch status {
    case errSecSuccess:
      return
    default:
      throw KeychainError(status: status)
    }
  }

  func generateQuery(with mutator: ((inout Query) -> Void)? = nil) -> Query {
    var query: Query = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: serviceName,
      kSecAttrAccessible: accessibility.attribute,
      kSecAttrAccount: account,
    ]
    mutator?(&query)
    return query
  }
}
