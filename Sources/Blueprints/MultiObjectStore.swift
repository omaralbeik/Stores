/// An API for a key-value store that offers a convenient and type-safe way to store and retrieve a collection of
/// `Codable` and `Identifiable` objects.
public protocol MultiObjectStore {
  // Storable object.
  associatedtype Object: Codable & Identifiable

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  func save(_ object: Object) throws

  /// Saves an optional object to store —if not nil—.
  /// **This method has a default implementation.**
  /// - Parameter object: optional object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  func save(_ object: Object?) throws

  /// Saves an array of objects to store.
  /// **This method has a default implementation.**
  /// - Parameter objects: array of objects to be saved.
  /// - Throws error: any error that might occur during the save operation.
  func save(_ objects: [Object]) throws

  /// The number of all objects stored in store.
  var objectsCount: Int { get }

  /// Wether the store contains a saved object with the given id.
  /// - Parameter id: object id.
  /// - Returns: true if store contains an object with the given id.
  func containsObject(withId id: Object.ID) -> Bool

  /// Returns an object for the given id, or `nil` if no object is found.
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or`nil` if no object with the given id is found.
  func object(withId id: Object.ID) -> Object?

  /// Returns objects for given ids, and ignores any ids that does not represent an object in the store.
  /// **This method has a default implementation.**
  /// - Parameter ids: object ids.
  /// - Returns: array of objects with the given ids.
  func objects(withIds ids: [Object.ID]) -> [Object]

  /// Returns all objects in the store.
  /// - Returns: collection containing all objects stored in store without a given order.
  func allObjects() -> [Object]

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be removed.
  /// - Throws error: any error that might occur during the removal operation.
  func remove(withId id: Object.ID) throws

  /// Removes objects with given ids —if found—, and ignore any ids that does not represent objects stored
  /// in the store.
  /// **This method has a default implementation.**
  /// - Parameter ids: ids for the objects to be deleted.
  /// - Throws error: any error that might occur during the removal operation.
  func remove(withIds ids: [Object.ID]) throws

  /// Removes all objects in store.
  /// - Throws error: any errors that might occur during the removal operation.
  func removeAll() throws
}

public extension MultiObjectStore {
  /// Saves an optional object to store —if not nil—.
  /// - Parameter object: optional object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  func save(_ object: Object?) throws {
    if let object = object {
      try save(object)
    }
  }

  /// Saves an array of objects to store.
  /// - Parameter objects: array of objects to be saved.
  /// - Throws error: any error that might occur during the save operation.
  func save(_ objects: [Object]) throws {
    try objects.forEach(save)
  }

  /// Returns objects for given ids, and ignores any ids that does not represent an object in the store.
  /// - Parameter ids: object ids.
  /// - Returns: array of objects with the given ids.
  func objects(withIds ids: [Object.ID]) -> [Object] {
    return ids.compactMap(object(withId:))
  }

  /// Removes objects with given ids —if found—, and ignore any ids that does not represent objects stored
  /// in the store.
  /// - Parameter ids: ids for the objects to be deleted.
  /// - Throws error: any error that might occur during the removal operation.
  func remove(withIds ids: [Object.ID]) throws {
    try ids.forEach(remove(withId:))
  }
}

public extension MultiObjectStore where Object: Hashable {
  /// Saves a set of objects to store.
  /// - Parameter objects: array of objects to be saved.
  /// - Throws error: any error that might occur during the save operation.
  func save(_ objects: Set<Object>) throws {
    try save(Array(objects))
  }
}
