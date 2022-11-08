#if canImport(Security)

import Blueprints
import Foundation
import Security

/// The single keychain object store is an implementation of `SingleObjectStore` that offers a
/// convenient and type-safe way to store and retrieve a single `Codable` object securely in and from the keychain.
///
/// > Thread safety: This is a thread-safe class.
public final class SingleKeychainStore<Object: Codable>: SingleObjectStore {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let lock = NSRecursiveLock()
  let logger = Logger()
  let key = "object"

  /// Store's unique identifier.
  ///
  /// Note: This is used to create the underlying service name `kSecAttrService` where the object is
  /// stored.
  ///
  /// `com.omaralbeik.stores.single.{identifier}`
  ///
  /// > Important: Never use the same identifier for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  public let identifier: String

  /// Store's accessibility level.
  public let accessibility: KeychainAccessibility

  /// Initialize store.
  ///
  /// Note: This is used to create the underlying service name `kSecAttrService` where the object is
  /// stored.
  ///
  /// `com.omaralbeik.stores.single.{identifier}`
  ///
  /// > Important: Never use the same identifier for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  ///
  /// - Parameters:
  ///   - identifier: store's unique identifier.
  ///   - accessibility: store's accessibility level. Defaults to `.whenUnlockedThisDeviceOnly`
  ///
  /// > Note: Creating a store is a fairly cheap operation, you can create multiple instances of the same store
  /// with same parameters.
  required public init(
    identifier: String,
    accessibility: KeychainAccessibility = .whenUnlockedThisDeviceOnly
  ) {
    self.identifier = identifier
    self.accessibility = accessibility
  }

  // MARK: - SingleObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(object)
      try addOrUpdate(data)
    }
  }

  /// Returns the object saved in the store.
  ///
  /// > Note: Errors thrown while performing the security query will be ignored and logged out to console
  /// in DEBUG.
  ///
  /// - Returns: object saved in the store. `nil` if no object is saved in store.
  public func object() -> Object? {
    let query = generateQuery {
      $0[kSecReturnData] = kCFBooleanTrue
      $0[kSecMatchLimit] = kSecMatchLimitOne
    }
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    switch status {
    case errSecSuccess:
      break
    default:
      logger.log(KeychainError.keychain(status))
      return nil
    }
    guard let data = result as? Data else {
      logger.log(KeychainError.invalidResult)
      return nil
    }
    do {
      return try decoder.decode(Object.self, from: data)
    } catch {
      logger.log(error)
      return nil
    }
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
        throw KeychainError.keychain(status)
      }
    }
  }
}

// MARK: - Helpers

extension SingleKeychainStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    defer { lock.unlock() }
    try action()
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
      throw KeychainError.keychain(status)
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
      throw KeychainError.keychain(status)
    }
  }

  func serviceName() -> String {
    return "com.omaralbeik.stores.single.\(identifier)"
  }

  func generateQuery(with mutator: ((inout Query) -> Void)? = nil) -> Query {
    var query: Query = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: serviceName(),
      kSecAttrAccessible: accessibility.attribute,
      kSecAttrAccount: key,
    ]
    mutator?(&query)
    return query
  }
}

#endif
