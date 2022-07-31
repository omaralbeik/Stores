import Blueprints
import Foundation

@_implementationOnly import SQLite

/// A single SQLite object store offers a convenient way to store and retrieve a single `Codable` object to a SQLite data base.
public final class SingleSQLiteStore<Object: Codable>: SingleObjectStore {
  public init() {}

  // MARK: - Store

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any encoding errors.
  public func save(_ object: Object) throws {
    fatalError("Unimplemented")
  }

  /// Returns the object saved in the store
  /// - Returns: object saved in the store. `nil` if no object is saved in store.
  public func object() -> Object? {
    fatalError("Unimplemented")
  }

  /// Removes any saved object in the store.
  public func remove() {
    fatalError("Unimplemented")
  }
}
