import Blueprints
import CoreData
import Foundation

public final class SingleCoreDataStore<Object: Codable>: SingleObjectStore {
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let lock = NSRecursiveLock()
  private let key = "object"

  let storage: CoreDataStorage

  public let databaseName: String

  public init(databaseName: String) {
    self.databaseName = databaseName
    self.storage = .init(databaseName: databaseName)
  }

  // MARK: - Store

  public func save(_ object: Object) throws {
    let data = try encoder.encode(object)
    let request = Entity.fetchRequest()
    if let savedEntity = try storage.context.fetch(request).first {
      savedEntity.data = data
    } else {
      let newEntity = Entity(context: storage.context)
      newEntity.id = key
      newEntity.data = data
    }
    try storage.context.save()
  }

  public func object() -> Object? {
    let request = Entity.fetchRequest()

    do {
      let result = try storage.context.fetch(request)
      guard let data = result.first?.data else { return nil }
      return try decoder.decode(Object.self, from: data)
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }

  public func remove() throws {
    let request = Entity.fetchRequest()
    let entities = try storage.context.fetch(request)
    for entity in entities {
      storage.context.delete(entity)
    }
    try storage.context.save()
  }
}
