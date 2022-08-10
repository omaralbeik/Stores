/// An API for a single object store offers a convenient and type-safe way to store and retrieve a single
/// `Codable` object.
public protocol SingleObjectStore {
  // Storable object.
  associatedtype Object: Codable

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  func save(_ object: Object) throws

  /// Saves an optional object to store or remove currently saved object if `nil`.
  /// **This method has a default implementation.**
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  func save(_ object: Object?) throws

  /// Returns the object saved in the store
  /// - Returns: object saved in the store. `nil` if no object is saved in store.
  func object() -> Object?

  /// Removes any saved object in the store.
  /// - Throws error: any error that might occur during the removal operation.
  func remove() throws
}

public extension SingleObjectStore {
  /// Saves an optional object to store or remove currently saved object if `nil`.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  func save(_ object: Object?) throws {
    if let object = object {
      try save(object)
    } else {
      try remove()
    }
  }
}
