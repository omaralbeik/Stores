import Blueprints
import CoreData
import Foundation

public final class MultiCoreDataStore<Object: Codable & Identifiable>: MultiObjectStore {
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let lock = NSRecursiveLock()

  let storage: CoreDataStorage

  public let databaseName: String

  public init(databaseName: String) {
    self.databaseName = databaseName
    self.storage = .init(databaseName: databaseName)
  }

  // MARK: - Store

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any encoding errors.
  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(object)
      let key = key(for: object)
      let request = Entity.fetchRequest(id: key)
      if let savedEntity = try storage.context.fetch(request).first {
        savedEntity.data = data
      } else {
        let newEntity = Entity(context: storage.context)
        newEntity.id = key
        newEntity.data = data
      }
      try storage.context.save()
    }
  }

  /// Saves an array of objects to store.
  /// - Parameter objects: array of objects to be saved.
  /// - Throws error: any encoding errors.
  public func save(_ objects: [Object]) throws {
    try sync {
      let pairs = try objects.map({ (key: key(for: $0), data: try encoder.encode($0)) })
      try pairs.forEach { pair in
        let request = Entity.fetchRequest(id: pair.key)
        if let savedEntity = try storage.context.fetch(request).first {
          savedEntity.data = pair.data
        } else {
          let newEntity = Entity(context: storage.context)
          newEntity.id = pair.key
          newEntity.data = pair.data
        }
      }
      try storage.context.save()
    }
  }

  /// The number of all objects stored in store.
  public var objectsCount: Int {
    let request = Entity.fetchRequest()
    do {
      return try storage.context.count(for: request)
    } catch {
      print(error.localizedDescription)
      return 0
    }
  }

  /// Wether the store contains a saved object with the given id.
  public func containsObject(withId id: Object.ID) -> Bool {
    let key = key(for: id)
    let request = Entity.fetchRequest(id: key)
    do {
      let count = try storage.context.count(for: request)
      return count != 0
    } catch {
      print(error.localizedDescription)
      return false
    }
  }

  /// Returns an object for the given id, or `nil` if no object is found.
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or`nil` if no object with the given id is found.
  public func object(withId id: Object.ID) -> Object? {
    let request = Entity.fetchRequest(id: key(for: id))
    do {
      guard let data = try storage.context.fetch(request).first?.data else {
        return nil
      }
      return try decoder.decode(Object.self, from: data)
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }

  /// Returns all objects in the store.
  /// - Returns: collection containing all objects stored in store.
  public func allObjects() -> [Object] {
    let request = Entity.fetchRequest()
    do {
      return try storage.context.fetch(request)
        .compactMap(\.data)
        .compactMap { try decoder.decode(Object.self, from: $0) }

    } catch {
      print(error.localizedDescription)
      return []
    }
  }

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withId id: Object.ID) throws {
    try sync {
      let request = Entity.fetchRequest(id: key(for: id))
      if let object = try storage.context.fetch(request).first {
        storage.context.delete(object)
      }
      try storage.context.save()
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
      let entities = try storage.context.fetch(request)
      for entity in entities {
        storage.context.delete(entity)
      }
      try storage.context.save()  }
  }
}

// MARK: - Helpers

private extension MultiCoreDataStore {
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
