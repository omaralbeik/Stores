import Blueprints
import Foundation

/// The multi object user defaults store is an implementation of ``MultiObjectStore`` that offers a
/// convenient and type-safe way to store and retrieve a collection of `Codable` and `Identifiable`
/// objects in a user defaults suite.
///
/// > Thread safety: This is a thread-safe class.
public final class MultiUserDefaultsStore<
  Object: Codable & Identifiable
>: MultiObjectStore {
  let store: UserDefaults
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let lock = NSRecursiveLock()

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

  // MARK: - MultiObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(object)
      let key = key(for: object)
      if store.object(forKey: key) == nil {
        increaseCounter()
      }
      store.set(data, forKey: key)
    }
  }

  /// Saves an array of objects to store.
  /// - Parameter objects: array of objects to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ objects: [Object]) throws {
    try sync {
      let pairs = try objects.map { object -> (key: String, data: Data) in
        let key = key(for: object)
        let data = try encoder.encode(object)
        return (key, data)
      }
      pairs.forEach { pair in
        if store.object(forKey: pair.key) == nil {
          increaseCounter()
        }
        store.set(pair.data, forKey: pair.key)
      }
    }
  }

  /// The number of all objects stored in store.
  public var objectsCount: Int {
    return store.integer(forKey: counterKey)
  }

  /// Whether the store contains a saved object with the given id.
  /// - Parameter id: object id.
  /// - Returns: true if store contains an object with the given id.
  public func containsObject(withId id: Object.ID) -> Bool {
    return object(withId: id) != nil
  }

  /// Returns an object for the given id, or `nil` if no object is found.
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or`nil` if no object with the given id is found.
  public func object(withId id: Object.ID) -> Object? {
    guard let data = store.data(forKey: key(for: id)) else { return nil }
    return try? decoder.decode(Object.self, from: data)
  }

  /// Returns all objects in the store.
  /// - Returns: collection containing all objects stored in store.
  public func allObjects() -> [Object] {
    guard objectsCount > 0 else { return [] }
    return store.dictionaryRepresentation().keys.compactMap { key -> Object? in
      guard isObjectKey(key) else { return nil }
      guard let data = store.data(forKey: key) else { return nil }
      return try? decoder.decode(Object.self, from: data)
    }
  }

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withId id: Object.ID) {
    sync {
      guard containsObject(withId: id) else { return }
      store.removeObject(forKey: key(for: id))
      decreaseCounter()
    }
  }

  /// Removes objects with given ids —if found—.
  /// - Parameter ids: ids for the objects to be deleted.
  public func remove(withIds ids: [Object.ID]) {
    sync {
      ids.forEach(remove(withId:))
    }
  }

  /// Removes all objects in store.
  public func removeAll() {
    sync {
      store.removePersistentDomain(forName: identifier)
      store.removeSuite(named: identifier)
    }
  }
}

// MARK: - Helpers

extension MultiUserDefaultsStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    defer { lock.unlock() }
    try action()
  }

  func increaseCounter() {
    let currentCount = store.integer(forKey: counterKey)
    store.set(currentCount + 1, forKey: counterKey)
  }

  func decreaseCounter() {
    let currentCount = store.integer(forKey: counterKey)
    if currentCount - 1 >= 0 {
      store.set(currentCount - 1, forKey: counterKey)
    }
  }

  var counterKey: String {
    return "\(identifier)-count"
  }

  func key(for object: Object) -> String {
    return key(for: object.id)
  }

  func key(for id: Object.ID) -> String {
    return "\(identifier)-\(id)"
  }

  func isObjectKey(_ key: String) -> Bool {
    return key.starts(with: "\(identifier)-")
  }
}
