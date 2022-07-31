import Blueprints
import Foundation

/// A single file system object store offers a convenient way to store and retrieve a single `Codable` object to the file system.
public final class SingleFileSystemStore<Object: Codable>: SingleObjectStore {
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
