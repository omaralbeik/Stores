#if canImport(CoreData)

import Blueprints
import CoreData
import Foundation

/// The multi object core data store is an implementation of ``MultiObjectStore`` that offers a
/// convenient and type-safe way to store and retrieve a collection of `Codable` and `Identifiable`
/// objects in a core data database.
///
/// > Thread safety: This is a thread-safe class.
public final class MultiCoreDataStore<
  Object: Codable & Identifiable
>: MultiObjectStore {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let lock = NSRecursiveLock()
  let database: Database
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

  // MARK: - MultiObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(object)
      let key = key(for: object)
      let request = database.entityFetchRequest(key)
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

  /// Saves an array of objects to store.
  /// - Parameter objects: array of objects to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ objects: [Object]) throws {
    try sync {
      let pairs = try objects.map { object -> (key: String, data: Data) in
        let key = key(for: object)
        let data = try encoder.encode(object)
        return (key, data)
      }
      try pairs.forEach { pair in
        let request = database.entityFetchRequest(pair.key)
        if let savedEntity = try database.context.fetch(request).first {
          savedEntity.data = pair.data
          savedEntity.lastUpdated = Date()
        } else {
          let newEntity = Entity(context: database.context)
          newEntity.id = pair.key
          newEntity.data = pair.data
          newEntity.lastUpdated = Date()
        }
      }
      try database.context.save()
    }
  }

  /// The number of all objects stored in store.
  ///
  /// > Note: Errors thrown out by performing the Core Data requests will be ignored and logged out to
  /// console in DEBUG.
  public var objectsCount: Int {
    let request = database.entitiesFetchRequest()
    do {
      let count = try logger.perform(database.context.count(for: request))
      return count
    } catch {
      logger.log(error)
      return 0
    }
  }

  /// Whether the store contains a saved object with the given id.
  ///
  /// > Note: Errors thrown out by performing the Core Data requests will be ignored and logged out to
  /// console in DEBUG.
  ///
  /// - Parameter id: object id.
  /// - Returns: true if store contains an object with the given id.
  public func containsObject(withId id: Object.ID) -> Bool {
    let key = key(for: id)
    let request = database.entityFetchRequest(key)
    do {
      let count = try logger.perform(database.context.count(for: request))
      return count != 0
    } catch {
      logger.log(error)
      return false
    }
  }

  /// Returns an object for the given id, or `nil` if no object is found.
  ///
  /// > Note: Errors thrown out by performing the Core Data requests will be ignored and logged out to
  /// console in DEBUG.
  ///
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or`nil` if no object with the given id is found.
  public func object(withId id: Object.ID) -> Object? {
    let request = database.entityFetchRequest(key(for: id))
    do {
      guard let data = try database.context.fetch(request).first?.data else {
        return nil
      }
      return try decoder.decode(Object.self, from: data)
    } catch {
      logger.log(error)
      return nil
    }
  }

  /// Returns all objects in the store.
  ///
  /// > Note: Errors thrown out by performing the Core Data requests will be ignored and logged out to
  /// console in DEBUG.
  ///
  /// - Returns: collection containing all objects stored in store.
  public func allObjects() -> [Object] {
    let request = database.entitiesFetchRequest()
    do {
      return try logger.perform(
        database.context.fetch(request)
          .compactMap(\.data)
          .compactMap {
            do {
              return try decoder.decode(Object.self, from: $0)
            } catch {
              logger.log(error)
              return nil
            }
          }
      )
    } catch {
      logger.log(error)
      return []
    }
  }

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withId id: Object.ID) throws {
    try sync {
      let request = database.entityFetchRequest(key(for: id))
      if let object = try database.context.fetch(request).first {
        database.context.delete(object)
      }
      try database.context.save()
    }
  }

  /// Removes objects with given ids —if found—.
  /// - Parameter ids: ids for the objects to be deleted.
  public func remove(withIds ids: [Object.ID]) throws {
    try sync {
      try ids.forEach(remove(withId:))
    }
  }

  /// Removes all objects in store.
  public func removeAll() throws {
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

// MARK: - Helpers

extension MultiCoreDataStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    defer { lock.unlock() }
    try action()
  }

  func key(for object: Object) -> String {
    return key(for: object.id)
  }

  func key(for id: Object.ID) -> String {
    return "\(databaseName)-\(id)"
  }
}

#endif
