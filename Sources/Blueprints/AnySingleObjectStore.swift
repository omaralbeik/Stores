/// A type erased `SingleObjectStore`.
public final class AnySingleObjectStore<Object: Codable>: SingleObjectStore {
  /// Create any store from a given store.
  /// - Parameter store: store to erase its type.
  public init<Store: SingleObjectStore>(
    _ store: Store
  ) where Store.Object == Object {
    _save = { try store.save($0) }
    _saveOptional = { try store.save($0) }
    _object = { store.object() }
    _remove = { try store.remove() }
  }

  private let _save: (Object) throws -> Void
  private let _saveOptional: (Object?) throws -> Void
  private let _object: () -> Object?
  private let _remove: () throws -> Void

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object) throws {
    try _save(object)
  }

  /// Saves an optional object to store or remove currently saved object if `nil`.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object?) throws {
    try _saveOptional(object)
  }

  /// Returns the object saved in the store
  /// - Returns: object saved in the store. `nil` if no object is saved in store.
  public func object() -> Object? {
    return _object()
  }

  /// Removes any saved object in the store.
  /// - Throws error: any error that might occur during the removal operation.
  public func remove() throws {
    try _remove()
  }
}

public extension SingleObjectStore {
  /// Create a type erased store.
  /// - Returns: `AnySingleObjectStore`.
  func eraseToAnyStore() -> AnySingleObjectStore<Object> {
    return .init(self)
  }
}
