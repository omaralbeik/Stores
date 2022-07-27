import Blueprints
import Foundation

public final class MultiUserDefaultsStore<Object: Codable & Identifiable>: MultiObjectStore {
  private let store: UserDefaults
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let lock = NSRecursiveLock()
  
  private func sync(action: () throws -> Void) rethrows {
    lock.lock()
    try action()
    lock.unlock()
  }
  
  /// Store's unique identifier.
  ///
  /// **Warning**: Never use the same identifier for more than two -or more- different stores.
  public let uniqueIdentifier: String
  
  /// Initialize store with given identifier.
  ///
  /// **Warning**: Never use the same identifier for two -or more- different stores.
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
  
  public func save(_ objects: [Object]) throws {
    try sync {
      let pairs = try objects.map({ (key: key(for: $0), data: try encoder.encode($0)) })
      pairs.forEach { pair in
        if store.object(forKey: pair.key) == nil {
          increaseCounter()
        }
        store.set(pair.data, forKey: pair.key)
      }
    }
  }
  
  public var objectsCount: Int {
    return store.integer(forKey: counterKey)
  }
  
  public func containsObject(withId id: Object.ID) -> Bool {
    return object(withId: id) != nil
  }
  
  public func object(withId id: Object.ID) -> Object? {
    guard let data = store.data(forKey: key(for: id)) else { return nil }
    return try? decoder.decode(Object.self, from: data)
  }
  
  public func allObjects() -> [Object] {
    guard objectsCount > 0 else { return [] }
    return store.dictionaryRepresentation().keys.compactMap { key -> Object? in
      guard isObjectKey(key) else { return nil }
      guard let data = store.data(forKey: key) else { return nil }
      return try? decoder.decode(Object.self, from: data)
    }
  }
  
  public func remove(withId id: Object.ID) {
    sync {
      guard containsObject(withId: id) else { return }
      store.removeObject(forKey: key(for: id))
      decreaseCounter()
    }
  }
  
  public func remove(withIds ids: [Object.ID]) {
    sync {
      ids.forEach(remove(withId:))
    }
  }
  
  public func removeAll() {
    sync {
      store.removePersistentDomain(forName: uniqueIdentifier)
      store.removeSuite(named: uniqueIdentifier)
    }
  }
}

// MARK: - Helpers

private extension MultiUserDefaultsStore {
  func increaseCounter() {
    let currentCount = store.integer(forKey: counterKey)
    store.set(currentCount + 1, forKey: counterKey)
  }
  
  func decreaseCounter() {
    let currentCount = store.integer(forKey: counterKey)
    guard currentCount > 0 else { return }
    guard currentCount - 1 >= 0 else { return }
    store.set(currentCount - 1, forKey: counterKey)
  }
  
  var counterKey: String {
    return "\(uniqueIdentifier)-count"
  }
  
  func key(for object: Object) -> String {
    return "\(uniqueIdentifier)-\(object.id)"
  }
  
  func key(for id: Object.ID) -> String {
    return "\(uniqueIdentifier)-\(id)"
  }
  
  func isObjectKey(_ key: String) -> Bool {
    return key.starts(with: "\(uniqueIdentifier)-")
  }
}