#if canImport(CoreData)

import Blueprints
import CoreData
import Foundation

/// The single core data object store is an implementation of `SingleObjectStore` that offers a
/// convenient and type-safe way to store and retrieve a single `Codable` object by saving it in a core data
/// database.
///
/// > Thread safety: This is a thread-safe class.
public final class SingleCoreDataStore<Object: Codable>: SingleObjectStore {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let lock = NSRecursiveLock()
  let database: Database
  let key = "object"
  let logger = Logger()

  /// Store's database name.
  ///
  /// > Important: Never use the same name for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  public let databaseName: String

  /// Initialize store with given database name.
  ///
  /// > Important: Never use the same name for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  ///
  /// - Parameter databaseName: store's database name.
  ///
  /// > Note: Creating a store is a fairly cheap operation, you can create multiple instances of the same store
  /// with a same database name.
  public init(databaseName: String) {
    self.databaseName = databaseName
    database = .init(name: databaseName)
  }

  /// URL for where the core data SQLite database is stored.
  public var databaseURL: URL? {
    database.url
  }

  // MARK: - SingleObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(object)
      let request = database.entitiesFetchRequest()
      if let savedEntity = try database.context.fetch(request).first {
        savedEntity.data = data
        savedEntity.lastUpdated = Date()
      } else {
        let newEntity = Entity(context: database.context)
        newEntity.id = key
        newEntity.data = data
        newEntity.lastUpdated = Date()
      }
      try database.context.save()
    }
  }

  /// Returns the object saved in the store.
  ///
  /// > Note: Errors thrown out by performing the Core Data requests will be ignored and logged out to
  /// console in DEBUG.
  ///
  /// - Returns: object saved in the store. `nil` if no object is saved in store.
  public func object() -> Object? {
    let request = database.entitiesFetchRequest()

    do {
      let result = try database.context.fetch(request)
      guard let data = result.first?.data else { return nil }
      return try decoder.decode(Object.self, from: data)
    } catch {
      logger.log(error)
      return nil
    }
  }

  /// Removes any saved object in the store.
  /// - Throws error: any error that might occur during the removal operation.
  public func remove() throws {
    try sync {
      let request = database.entitiesFetchRequest()
      let entities = try database.context.fetch(request)
      for entity in entities {
        database.context.delete(entity)
      }
      try database.context.save()
    }
  }
}

extension SingleCoreDataStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    defer { lock.unlock() }
    try action()
  }
}

#endif
