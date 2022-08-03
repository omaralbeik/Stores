import Blueprints
import Foundation

/// A single UserDefaults object store offers a convenient way to store and retrieve a single `Codable` object to UserDefaults.
public final class SingleUserDefaultsStore<Object: Codable>: SingleObjectStore {
  private let store: UserDefaults
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let lock = NSRecursiveLock()
  private let key = "object"

  /// Store's unique identifier.
  ///
  /// **Warning**: Never use the same identifier for multiple stores with different object types, doing this might cause stores to have corrupted data.
  public let uniqueIdentifier: String

  /// Initialize store with given identifier.
  ///
  /// **Warning**: Never use the same identifier for multiple stores with different object types, doing this might cause stores to have corrupted data.
  ///
  /// - Parameter uniqueIdentifier: store's unique identifier.
  required public init(uniqueIdentifier: String) {
    guard let store = UserDefaults(suiteName: uniqueIdentifier) else {
      preconditionFailure("Can not create a store with identifier: '\(uniqueIdentifier)'.")
    }
    self.uniqueIdentifier = uniqueIdentifier
    self.store = store
  }

  // MARK: - Store

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
      store.removePersistentDomain(forName: uniqueIdentifier)
      store.removeSuite(named: uniqueIdentifier)
    }
  }
}

// MARK: - Helpers

private extension SingleUserDefaultsStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    try action()
    lock.unlock()
  }
}
