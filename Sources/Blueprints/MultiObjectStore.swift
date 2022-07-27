public protocol MultiObjectStore {
  // Storable object.
  associatedtype Object: Codable & Identifiable

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  func save(_ object: Object) throws

  /// Saves an array of objects to store.
  /// - Parameter objects: array of objects to be saved.
  func save(_ objects: [Object]) throws

  /// The number of all objects stored in store.
  var objectsCount: Int { get }

  /// Wether the store contains a saved object with the given id.
  func containsObject(withId id: Object.ID) -> Bool

  /// Returns an object for the given id, or `nil` if no object is found.
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or`nil` if no object with the given id is found.
  func object(withId id: Object.ID) -> Object?

  /// Returns objects for given ids.
  /// - Parameter ids: object ids.
  /// - Returns: array of objects with the given ids.
  func objects(withIds ids: [Object.ID]) -> [Object]

  /// Returns all objects in the store.
  /// - Returns: collection containing all objects stored in store.
  func allObjects() -> [Object]

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be deleted.
  func remove(withId id: Object.ID)

  /// Removes objects with given ids —if found—.
  /// - Parameter id: id for the object to be deleted.
  func remove(withIds ids: [Object.ID])

  /// Removes all objects in store.
  func removeAll()
}

public extension MultiObjectStore {
  func save(_ objects: [Object]) throws {
    try objects.forEach(save)
  }

  func objects(withIds ids: [Object.ID]) -> [Object] {
    return ids.compactMap(object(withId:))
  }

  func remove(withIds ids: [Object.ID]) {
    ids.forEach(remove(withId:))
  }
}

public extension MultiObjectStore {
  subscript(id: Object.ID) -> Object? {
    get {
      return object(withId: id)
    }
    set {
      guard let object = newValue else { return }
      try? save(object)
    }
  }
}
