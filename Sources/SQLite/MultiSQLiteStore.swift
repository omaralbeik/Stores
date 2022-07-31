import Blueprints
import Foundation

@_implementationOnly import SQLite

/// A multi object SQLite store offers a convenient way to store and retrieve a collection of `Codable` and `Identifiable` objects to a SQLite data base.
public final class MultiSQLiteStore<Object: Codable & Identifiable>: MultiObjectStore {
  public init() {}

  public func save(_ object: Object) throws {
    fatalError("Unimplemented")
  }
  
  public var objectsCount: Int {
    fatalError("Unimplemented")
  }
  
  public func containsObject(withId id: Object.ID) -> Bool {
    fatalError("Unimplemented")
  }
  
  public func object(withId id: Object.ID) -> Object? {
    fatalError("Unimplemented")
  }
  
  public func allObjects() -> [Object] {
    fatalError("Unimplemented")
  }
  
  public func remove(withId id: Object.ID) {
    fatalError("Unimplemented")
  }
  
  public func removeAll() {
    fatalError("Unimplemented")
  }
}
