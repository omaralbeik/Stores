import Blueprints
import Foundation

/// The single UserDefaults object store offers a convenient and type-safe way to store and retrieve a single
/// `Codable` object to UserDefaults.
///
/// > Thread safety: This is a thread-safe class.
public final class SingleUserDefaultsStore<Object: Codable>: SingleObjectStore {
  let store: UserDefaults
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let lock = NSRecursiveLock()
  let key = "object"

  /// Store's unique identifier.
  ///
  /// > Note: This is used as the suite name for the underlying UserDefaults store.
  ///
  /// > Important: Never use the same identifier for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  public let identifier: String

  /// Initialize store with given identifier.
  ///
  /// > Note: This is used as the suite name for the underlying UserDefaults store. Using an invalid name like
  /// `default` will cause a precondition failure.
  ///
  /// > Important: Never use the same identifier for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  ///
  /// - Parameter identifier: store's unique identifier.
  ///
  /// > Note: Creating a store is a fairly cheap operation, you can create multiple instances of the same store
  /// with a same identifier.
  public required init(identifier: String) {
    guard let store = UserDefaults(suiteName: identifier) else {
      preconditionFailure(
        "Can not create store with identifier: '\(identifier)'."
      )
    }
    self.identifier = identifier
    self.store = store
  }

  // MARK: - SingleObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any encoding errors.
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
  public func remove() {
    sync {
      store.removePersistentDomain(forName: identifier)
      store.removeSuite(named: identifier)
    }
  }
}

// MARK: - Helpers

extension SingleUserDefaultsStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    try action()
    lock.unlock()
  }
}
