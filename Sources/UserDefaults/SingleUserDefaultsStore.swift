import Blueprints
import Foundation

public final class SingleUserDefaultsStore<Object: Codable>: SingleObjectStore {
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
  /// **Warning**: Never use the same identifier for two -or more- different stores.
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

  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(generateDict(for: object))
      store.set(data, forKey: key)
    }
  }

  public func object() -> Object? {
    guard let data = store.data(forKey: key) else { return nil }
    guard let dict = try? decoder.decode([String: Object].self, from: data) else { return nil }
    return extractObject(from: dict)
  }

  public func remove() {
    sync {
      store.removePersistentDomain(forName: uniqueIdentifier)
      store.removeSuite(named: uniqueIdentifier)
    }
  }
}

// MARK: - Helpers

private extension SingleUserDefaultsStore {
  func generateDict(for object: Object) -> [String: Object] {
    return ["object": object]
  }

  func extractObject(from dict: [String: Object]) -> Object? {
    return dict["object"]
  }

  var key: String {
    return "\(uniqueIdentifier)-single-object"
  }
}
