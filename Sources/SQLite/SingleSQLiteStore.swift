import Blueprints
import Foundation

@_implementationOnly import SQLite

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
