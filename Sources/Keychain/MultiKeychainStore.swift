#if canImport(Security)

import Blueprints
import Foundation
import Security

/// The multi object keychain store is an implementation of `MultiObjectStore` that offers a
/// convenient and type-safe way to store and retrieve a collection of `Codable` and `Identifiable`
/// objects securely in the keychain.
///
/// > Thread safety: This is a thread-safe class.
public final class MultiKeychainStore<
  Object: Codable & Identifiable
>: MultiObjectStore {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let lock = NSRecursiveLock()
  let logger = Logger()

  /// Store's unique identifier.
  ///
  /// Note: This is used to create the underlying service name `kSecAttrService` where objects are
  /// stored.
  ///
  /// `com.omaralbeik.stores.multi.{identifier}`
  ///
  /// > Important: Never use the same identifier for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  public let identifier: String

  /// Store's accessibility level.
  public let accessibility: KeychainAccessibility

  /// Initialize store.
  ///
  /// Note: This is used to create the underlying service name `kSecAttrService` where objects are
  /// stored.
  ///
  /// `com.omaralbeik.stores.multi.{identifier}`
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

  // MARK: - MultiObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(object)
      try addOrUpdate(data: data, for: object.id)
    }
  }

  /// Saves an array of objects to store.
  /// - Parameter objects: array of objects to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ objects: [Object]) throws {
    try sync {
      let pairs = try objects.map { (try encoder.encode($0), $0.id) }
      try pairs.forEach(addOrUpdate)
    }
  }

  /// The number of all objects stored in store.
  ///
  /// > Note: Errors thrown while performing the security query will be ignored and logged out to console
  /// in DEBUG.
  public var objectsCount: Int {
    let query = generateQuery {
      $0[kSecMatchLimit] = kSecMatchLimitAll
    }
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    switch status {
    case errSecSuccess:
      break
    case errSecItemNotFound:
      return 0
    default:
      logger.log(KeychainError.keychain(status))
      return 0
    }
    guard let array = result as? NSArray else {
      logger.log(KeychainError.invalidResult)
      return 0
    }
    return array.count
  }

  /// Whether the store contains a saved object with the given id.
  ///
  /// > Note: Errors thrown while performing the security query will be ignored and logged out to console
  /// in DEBUG.
  ///
  /// - Parameter id: object id.
  /// - Returns: true if store contains an object with the given id.
  public func containsObject(withId id: Object.ID) -> Bool {
    let query = generateQuery(id: id) {
      $0[kSecMatchLimit] = kSecMatchLimitOne
    }
    let status = SecItemCopyMatching(query as CFDictionary, nil)
    switch status {
    case errSecSuccess:
      return true
    case errSecItemNotFound:
      return false
    default:
      logger.log(KeychainError.keychain(status))
      return false
    }
  }

  /// Returns an object for the given id, or `nil` if no object is found.
  ///
  /// > Note: Errors thrown while performing the security query will be ignored and logged out to console
  /// in DEBUG.
  ///
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or `nil` if no object with the given id is found.
  public func object(withId id: Object.ID) -> Object? {
    let query = generateQuery(id: id) {
      $0[kSecReturnData] = kCFBooleanTrue
      $0[kSecMatchLimit] = kSecMatchLimitOne
    }
    var result: AnyObject?
    SecItemCopyMatching(query as CFDictionary, &result)
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

  /// Returns all objects in the store.
  ///
  /// > Note: Errors thrown while performing the security query will be ignored and logged out to console
  /// in DEBUG.
  ///
  /// - Returns: collection containing all objects stored in store.
  public func allObjects() -> [Object] {
    let query = generateQuery {
      $0[kSecReturnAttributes] = kCFBooleanTrue
      $0[kSecMatchLimit] = kSecMatchLimitAll
    }
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    switch status {
    case errSecSuccess:
      break
    case errSecItemNotFound:
      return []
    default:
      logger.log(KeychainError.keychain(status))
      return []
    }
    guard let items = result as? [NSDictionary] else {
      logger.log(KeychainError.invalidResult)
      return []
    }
    return items.compactMap(extractObject)
  }

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withId id: Object.ID) throws {
    try sync {
      let query = generateQuery(id: id)
      let status = SecItemDelete(query as CFDictionary)
      switch status {
      case errSecSuccess, errSecItemNotFound:
        return
      default:
        throw KeychainError.keychain(status)
      }
    }
  }

  /// Removes objects with given ids —if found—.
  /// - Parameter ids: ids for the objects to be deleted.
  public func remove(withIds ids: [Object.ID]) throws {
    for id in ids where containsObject(withId: id) {
      try remove(withId: id)
    }
  }

  /// Removes all objects in store.
  public func removeAll() throws {
    try sync {
      let query = generateQuery() {
        $0[kSecMatchLimit] = kSecMatchLimitAll
      }
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

extension MultiKeychainStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    defer { lock.unlock() }
    try action()
  }

  func serviceName() -> String {
    return "com.omaralbeik.stores.multi.\(identifier)"
  }

  func key(for object: Object) -> String {
    return key(for: object.id)
  }

  func key(for id: Object.ID) -> String {
    return "\(identifier)-\(id)"
  }

  typealias Query = Dictionary<CFString, Any>

  func addOrUpdate(data: Data, for id: Object.ID) throws {
    let query = generateQuery(id: id) {
      $0[kSecValueData] = data
      $0[kSecAttrAccessible] = self.accessibility.attribute
    }
    let status = SecItemAdd(query as CFDictionary, nil)
    switch status {
    case errSecSuccess:
      return
    case errSecDuplicateItem:
      try update(data: data, for: id)
    default:
      throw KeychainError.keychain(status)
    }
  }

  func update(data: Data, for id: Object.ID) throws {
    let query = generateQuery(id: id) {
      $0[kSecAttrAccessible] = self.accessibility.attribute
    }
    let updateQuery = [kSecValueData: data]
    let status = SecItemUpdate(
      query as CFDictionary,
      updateQuery as CFDictionary
    )
    switch status {
    case errSecSuccess:
      return
    default:
      throw KeychainError.keychain(status)
    }
  }

  func extractObject(from dictionary: NSDictionary) -> Object? {
    let query = generateQuery {
      $0[kSecReturnData] = kCFBooleanTrue
      $0[kSecMatchLimit] = kSecMatchLimitOne
      $0[kSecAttrAccount] = dictionary[kSecAttrAccount]
    }
    var result: AnyObject?
    SecItemCopyMatching(query as CFDictionary, &result)
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

  func generateQuery(
    with mutator: ((inout Query) -> Void)? = nil
  ) -> Query {
    var query: Query = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrService: serviceName(),
    ]
    mutator?(&query)
    return query
  }

  func generateQuery(
    id: Object.ID,
    with mutator: ((inout Query) -> Void)? = nil
  ) -> Query {
    let key = key(for: id)
    return generateQuery {
      $0[kSecAttrAccount] = key
      mutator?(&$0)
    }
  }
}

#endif
