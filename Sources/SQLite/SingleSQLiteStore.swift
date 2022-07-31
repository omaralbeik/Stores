import Blueprints
import Foundation

@_implementationOnly import SQLite

/// A single SQLite object store offers a convenient way to store and retrieve a single `Codable` object to a SQLite data base.
public final class SingleSQLiteStore<Object: Codable>: SingleObjectStore {
  public init() {}

  public func save(_ object: Object) throws {
    fatalError("Unimplemented")
  }
  
  public func object() -> Object? {
    fatalError("Unimplemented")
  }
  
  public func remove() {
    fatalError("Unimplemented")
  }
}
