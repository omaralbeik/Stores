/// A single object store offers a convenient way to store and retrieve a single `Codable` object.
public protocol SingleObjectStore {
  // Storable object.
  associatedtype Object: Codable

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any encoding errors.
  func save(_ object: Object) throws

  /// Returns the object saved in the store
  /// - Returns: object saved in the store. `nil` if no object is saved in store.
  func object() -> Object?

  /// Removes any saved object in the store.
  func remove()
}
