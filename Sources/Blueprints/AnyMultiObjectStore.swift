/// A type-erased ``MultiObjectStore``.
public final class AnyMultiObjectStore<
  Object: Codable & Identifiable
>: MultiObjectStore {
  /// Create any store from a given store.
  /// - Parameter store: store to erase its type.
  public init<Store: MultiObjectStore>(
    _ store: Store
  ) where Store.Object == Object {
    _store = store
    _save = { try store.save($0) }
    _saveOptional = { try store.save($0) }
    _saveObjects = { try store.save($0) }
    _objectsCount = { store.objectsCount }
    _containsObject = { store.containsObject(withId: $0) }
    _object = { store.object(withId: $0) }
    _objects = { store.objects(withIds: $0) }
    _allObjects = { store.allObjects() }
    _remove = { try store.remove(withId: $0) }
    _removeMultiple = { try store.remove(withIds: $0) }
    _removeAll = { try store.removeAll() }
  }

  private let _store: any MultiObjectStore
  private let _save: (Object) throws -> Void
  private let _saveOptional: (Object?) throws -> Void
  private let _saveObjects: ([Object]) throws -> Void
  private let _objectsCount: () -> Int
  private let _containsObject: (Object.ID) -> Bool
  private let _object: (Object.ID) -> Object?
  private let _objects: ([Object.ID]) -> [Object]
  private let _allObjects: () -> [Object]
  private let _remove: (Object.ID) throws -> Void
  private let _removeMultiple: ([Object.ID]) throws -> Void
  private let _removeAll: () throws -> Void

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object) throws {
    try _save(object)
  }

  /// Saves an optional object to store —if not nil—.
  /// - Parameter object: optional object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object?) throws {
    try _saveOptional(object)
  }

  /// Saves an array of objects to store.
  /// - Parameter objects: array of objects to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ objects: [Object]) throws {
    try _saveObjects(objects)
  }

  /// The number of all objects stored in the store.
  public var objectsCount: Int {
    return _objectsCount()
  }

  /// Whether the store contains a saved object with the given id.
  /// - Parameter id: object id.
  /// - Returns: true if store contains an object with the given id.
  public func containsObject(withId id: Object.ID) -> Bool {
    return _containsObject(id)
  }

  /// Returns an object for the given id, or `nil` if no object is found.
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or `nil` if no object with the given id is found.
  public func object(withId id: Object.ID) -> Object? {
    return _object(id)
  }

  /// Returns objects for given ids, and ignores any ids that does not represent an object in the store.
  /// - Parameter ids: object ids.
  /// - Returns: array of objects with the given ids.
  public func objects(withIds ids: [Object.ID]) -> [Object] {
    return _objects(ids)
  }

  /// Returns all objects in the store.
  /// - Returns: collection containing all objects stored in store without a given order.
  public func allObjects() -> [Object] {
    return _allObjects()
  }

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be removed.
  /// - Throws error: any error that might occur during the removal operation.
  public func remove(withId id: Object.ID) throws {
    try _remove(id)
  }

  /// Removes objects with given ids —if found—, and ignore any ids that does not represent objects stored
  /// in the store.
  /// - Parameter ids: ids for the objects to be deleted.
  /// - Throws error: any error that might occur during the removal operation.
  public func remove(withIds ids: [Object.ID]) throws {
    try _removeMultiple(ids)
  }

  /// Removes all objects in store.
  /// - Throws error: any errors that might occur during the removal operation.
  public func removeAll() throws {
    try _removeAll()
  }
}

public extension MultiObjectStore {
  /// Create a type erased store.
  /// - Returns: ``AnyMultiObjectStore``.
  func eraseToAnyStore() -> AnyMultiObjectStore<Object> {
    if let anyStore = self as? AnyMultiObjectStore<Object> {
      return anyStore
    }
    return .init(self)
  }
}
