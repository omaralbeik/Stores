import Blueprints
import Foundation

public final class SingleFileSystemStore<Object: Codable>: SingleObjectStore {
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
