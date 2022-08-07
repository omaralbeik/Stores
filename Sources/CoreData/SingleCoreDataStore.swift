import Blueprints
import CoreData
import Foundation

// https://betterprogramming.pub/use-coredata-from-an-spm-package-e82c465d5d02

public final class SingleCoreDataStore<Object: Codable>: SingleObjectStore {
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let lock = NSRecursiveLock()
  private let key = "object"

  let context: NSManagedObjectContext

  public let databaseName: String

  public init(databaseName: String) {
    self.databaseName = databaseName

    let modelURL = Bundle.module.url(forResource: "Models", withExtension: "momd")!
    let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
    let container = NSPersistentContainer(name: databaseName, managedObjectModel: managedObjectModel)
    container.loadPersistentStores { _, error in
      if let error = error {
        preconditionFailure("Failed to load store with error: \(error).")
      }
    }
    context = container.viewContext
  }

  // MARK: - Store

  public func save(_ object: Object) throws {
    let data = try encoder.encode(object)
    let request = Entity.fetchRequest()
    if let savedEntity = try context.fetch(request).first {
      savedEntity.data = data
    } else {
      let newEntity = Entity(context: context)
      newEntity.id = key
      newEntity.data = data
    }
    try context.save()
  }

  public func object() -> Object? {
    let request = Entity.fetchRequest()

    do {
      let result = try context.fetch(request)
      guard let data = result.first?.data else { return nil }
      return try decoder.decode(Object.self, from: data)
    } catch {
      print(error.localizedDescription)
      return nil
    }
  }

  public func remove() throws {
    let request = Entity.fetchRequest()
    let entities = try context.fetch(request)
    for entity in entities {
      context.delete(entity)
    }
    try context.save()
  }
}
