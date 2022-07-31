import Blueprints
import Foundation

/// A multi object file system store offers a convenient way to store and retrieve a collection of `Codable` and `Identifiable` objects to the file system.
public final class MultiFileSystemStore<Object: Codable & Identifiable>: MultiObjectStore {
  public init() {}

  // MARK: - Store

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any encoding errors.
  public func save(_ object: Object) throws {
    fatalError("Unimplemented")
  }

  /// The number of all objects stored in store.
  public var objectsCount: Int {
    fatalError("Unimplemented")
  }

  /// Wether the store contains a saved object with the given id.
  public func containsObject(withId id: Object.ID) -> Bool {
    fatalError("Unimplemented")
  }

  /// Returns an object for the given id, or `nil` if no object is found.
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or`nil` if no object with the given id is found.
  public func object(withId id: Object.ID) -> Object? {
    fatalError("Unimplemented")
  }

  /// Returns all objects in the store.
  /// - Returns: collection containing all objects stored in store.
  public func allObjects() -> [Object] {
    fatalError("Unimplemented")
  }

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withId id: Object.ID) {
    fatalError("Unimplemented")
  }

  /// Removes all objects in store.
  public func removeAll() {
    fatalError("Unimplemented")
  }
}
