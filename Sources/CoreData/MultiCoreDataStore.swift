import Blueprints
import CoreData
import Foundation

/// The multi object Core Data store offers a convenient and type-safe way to store and retrieve a collection
/// of `Codable` and `Identifiable` objects to a Core Data database.
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
    self.database = .init(name: databaseName)
  }

  // MARK: - MultiObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any encoding errors.
  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(object)
      let key = key(for: object)
      let request = Entity.fetchRequest(id: key)
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
  /// - Throws error: any encoding errors.
  public func save(_ objects: [Object]) throws {
    try sync {
      let pairs = try objects.map { (
        key: key(for: $0),
        data: try encoder.encode($0)
      ) }
      try pairs.forEach { pair in
        let request = Entity.fetchRequest(id: pair.key)
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
    let request = Entity.fetchRequest()
    do {
      return try database.context.count(for: request)
    } catch {
      logger.log(error)
      return 0
    }
  }

  /// Wether the store contains a saved object with the given id.
  ///
  /// > Note: Errors thrown out by performing the Core Data requests will be ignored and logged out to
  /// console in DEBUG.
  ///
  /// - Parameter id: object id.
  /// - Returns: true if store contains an object with the given id.
  public func containsObject(withId id: Object.ID) -> Bool {
    let key = key(for: id)
    let request = Entity.fetchRequest(id: key)
    do {
      let count = try database.context.count(for: request)
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
    let request = Entity.fetchRequest(id: key(for: id))
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
    let request = Entity.fetchRequest()
    do {
      return try database.context.fetch(request)
        .compactMap(\.data)
        .compactMap { try decoder.decode(Object.self, from: $0) }

    } catch {
      logger.log(error)
      return []
    }
  }

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withId id: Object.ID) throws {
    try sync {
      let request = Entity.fetchRequest(id: key(for: id))
      if let object = try database.context.fetch(request).first {
        database.context.delete(object)
      }
      try database.context.save()
    }
  }

  /// Removes objects with given ids —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withIds ids: [Object.ID]) throws {
    try sync {
      try ids.forEach(remove(withId:))
    }
  }

  /// Removes all objects in store.
  public func removeAll() throws {
    try sync {
      let request = Entity.fetchRequest()
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
    try action()
    lock.unlock()
  }

  func key(for object: Object) -> String {
    return "\(databaseName)-\(object.id)"
  }

  func key(for id: Object.ID) -> String {
    return "\(databaseName)-\(id)"
  }
}
