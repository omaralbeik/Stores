import Blueprints
import CoreData
import Foundation

public final class SingleCoreDataStore<Object: Codable>: SingleObjectStore {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let lock = NSRecursiveLock()
  let database: Database
  let key = "object"

  public let databaseName: String

  public init(databaseName: String) {
    self.databaseName = databaseName
    self.database = .init(name: databaseName)
  }

  // MARK: - Store

  public func save(_ object: Object) throws {
    let data = try encoder.encode(object)
    let request = Entity.fetchRequest()
    if let savedEntity = try database.context.fetch(request).first {
      savedEntity.data = data
    } else {
      let newEntity = Entity(context: database.context)
      newEntity.id = key
      newEntity.data = data
    }
    try database.context.save()
  }

  public func object() -> Object? {
    let request = Entity.fetchRequest()

    do {
      let result = try database.context.fetch(request)
      guard let data = result.first?.data else { return nil }
      return try decoder.decode(Object.self, from: data)
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }

  public func remove() throws {
    let request = Entity.fetchRequest()
    let entities = try database.context.fetch(request)
    for entity in entities {
      database.context.delete(entity)
    }
    try database.context.save()
  }
}
