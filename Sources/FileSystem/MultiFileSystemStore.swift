import Blueprints
import Foundation

public final class MultiFileSystemStore<Object: Codable & Identifiable>: MultiObjectStore {
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
