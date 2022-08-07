import Blueprints
import CoreData
import Foundation

public final class MultiCoreDataStore<Object: Codable & Identifiable>: MultiObjectStore {
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let lock = NSRecursiveLock()

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

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any encoding errors.
  public func save(_ object: Object) throws {
  }

  /// Saves an array of objects to store.
  /// - Parameter objects: array of objects to be saved.
  /// - Throws error: any encoding errors.
  public func save(_ objects: [Object]) throws {
  }

  /// The number of all objects stored in store.
  public var objectsCount: Int {
    return 0
  }

  /// Wether the store contains a saved object with the given id.
  public func containsObject(withId id: Object.ID) -> Bool {
    return false
  }

  /// Returns an object for the given id, or `nil` if no object is found.
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or`nil` if no object with the given id is found.
  public func object(withId id: Object.ID) -> Object? {
    return nil
  }

  /// Returns all objects in the store.
  /// - Returns: collection containing all objects stored in store.
  public func allObjects() -> [Object] {
    return []
  }

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withId id: Object.ID) throws {
  }

  /// Removes objects with given ids —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withIds ids: [Object.ID]) throws {
  }

  /// Removes all objects in store.
  public func removeAll() throws {
  }
}
