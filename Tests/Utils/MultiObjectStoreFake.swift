import Blueprints
import Foundation

/// Multi object store fake that uses a dictionary to store and retrieve objects.
public final class MultiObjectStoreFake<Object: Codable & Identifiable>: MultiObjectStore {
  /// Dictionary used to store and retrieve objects.
  public var dictionary: [Object.ID: Object] = [:]

  /// Optional error. Setting this will make any throwing method of the store throw the set error.
  public var error: Error?

  /// Create a new store fake with a given dictionary and an option error to be thrown.
  /// - Parameters:
  ///   - dictionary: dictionary used to store and retrieve objects. Defaults to an empty dictionary.
  ///   - error: optional error. Setting this will make any throwing method of the store throw the set error. Defaults to `nil`.
  public init(dictionary: [Object.ID: Object] = [:], error: Error? = nil) {
    self.dictionary = dictionary
    self.error = error
  }

  // MARK: - Store

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any encoding errors.
  public func save(_ object: Object) throws {
    if let error = error {
      throw error
    }
    dictionary[object.id] = object
  }

  /// The number of all objects stored in store.
  public var objectsCount: Int { dictionary.count }

  /// Wether the store contains a saved object with the given id.
  public func containsObject(withId id: Object.ID) -> Bool {
    return dictionary[id] != nil
  }

  /// Returns an object for the given id, or `nil` if no object is found.
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or`nil` if no object with the given id is found.
  public func object(withId id: Object.ID) -> Object? {
    return dictionary[id]
  }

  /// Returns all objects in the store.
  /// - Returns: collection containing all objects stored in store.
  public func allObjects() -> [Object] {
    return Array(dictionary.values)
  }

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withId id: Object.ID) {
    dictionary[id] = nil
  }

  /// Removes all objects in store.
  public func removeAll() {
    dictionary = [:]
  }
}
