import Blueprints
import Foundation

/// Single object store fake that uses a property to store and retrieve objects.
public final class SingleObjectStoreFake<Object: Codable>: SingleObjectStore {
  /// Optional object.
  public var underlyingObject: Object?

  /// Optional error. Setting this will make any throwing method of the store throw the set error.
  public var error: Error?

  /// Create a new store fake with a given dictionary and an option error to be thrown.
  /// - Parameters:
  ///   - underlyingObject: optional object. Defaults to `nil`.
  ///   - error: optional error. Setting this will make any throwing method of the store throw the set error.
  ///   Defaults to `nil`.
  public init(
    underlyingObject: Object? = nil,
    error: Error? = nil
  ) {
    self.underlyingObject = underlyingObject
    self.error = error
  }

  // MARK: - SingleObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object) throws {
    if let error = error {
      throw error
    }
    underlyingObject = object
  }

  /// Returns the object saved in the store
  /// - Returns: object saved in the store. `nil` if no object is saved in store.
  public func object() -> Object? {
    return underlyingObject
  }

  /// Removes any saved object in the store.
  /// - Throws error: any error that might occur during the removal operation.
  public func remove() throws {
    if let error = error {
      throw error
    }
    underlyingObject = nil
  }
}
