import Blueprints
import Foundation

/// The single user defaults object store is an implementation of `SingleObjectStore` that offers a
/// convenient and type-safe way to store and retrieve a single `Codable` object to a user defaults suite.
///
/// > Thread safety: This is a thread-safe class.
public final class SingleUserDefaultsStore<Object: Codable>: SingleObjectStore {
  let store: UserDefaults
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let lock = NSRecursiveLock()
  let key = "object"

  /// Store's suite name.
  ///
  /// > Note: This is used as the suite name for the underlying UserDefaults store.
  ///
  /// > Important: Never use the same suite name for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  public let suiteName: String

  /// Initialize store with given suite name.
  ///
  /// > Note: This is used as the suite name for the underlying UserDefaults store. Using an invalid name like
  /// `default` will cause a precondition failure.
  ///
  /// > Important: Never use the same suite name for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  ///
  /// - Parameter suiteName: store's suite name.
  ///
  /// > Note: Creating a store is a fairly cheap operation, you can create multiple instances of the same store
  /// with a same suiteName.
  public required init(suiteName: String) {
    guard let store = UserDefaults(suiteName: suiteName) else {
      preconditionFailure(
        "Can not create store with suiteName: '\(suiteName)'."
      )
    }
    self.suiteName = suiteName
    self.store = store
  }


  // MARK: - Deprecated

  /// Deprecated: Store's unique identifier.
  @available(*, deprecated, renamed: "suiteName")
  public var identifier: String { suiteName }

  /// Deprecated: Initialize store with given identifier.
  @available(*, deprecated, renamed: "init(suiteName:)")
  public required init(identifier: String) {
    guard let store = UserDefaults(suiteName: identifier) else {
      preconditionFailure(
        "Can not create store with identifier: '\(identifier)'."
      )
    }
    self.suiteName = identifier
    self.store = store
  }

  // MARK: - SingleObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(object)
      store.set(data, forKey: key)
    }
  }

  /// Returns the object saved in the store
  /// - Returns: object saved in the store. `nil` if no object is saved in store.
  public func object() -> Object? {
    guard let data = store.data(forKey: key) else { return nil }
    return try? decoder.decode(Object.self, from: data)
  }

  /// Removes any saved object in the store.
  ///
  /// > Note: This removes the entire persistent domain for the underlying UserDefaults store.
  ///
  public func remove() {
    sync {
      store.removePersistentDomain(forName: suiteName)
      store.removeSuite(named: suiteName)
    }
  }
}

// MARK: - Helpers

extension SingleUserDefaultsStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    defer { lock.unlock() }
    try action()
  }
}
