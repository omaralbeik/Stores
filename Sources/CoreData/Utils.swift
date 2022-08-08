import CoreData

@objc(Entity)
final class Entity: NSManagedObject {
  @NSManaged var id: String?
  @NSManaged var data: Data?

  override var description: String {
    return "Entity"
  }

  @nonobjc
  class func fetchRequest() -> NSFetchRequest<Entity> {
    return NSFetchRequest<Entity>(entityName: "Entity")
  }

  @nonobjc
  class func fetchRequest(id: String) -> NSFetchRequest<Entity> {
    let request = NSFetchRequest<Entity>(entityName: "Entity")
    request.predicate = NSPredicate(format: "id == %@", id)
    return request
  }
}

// https://betterprogramming.pub/use-coredata-from-an-spm-package-e82c465d5d02

final class CoreDataStorage {
  let context: NSManagedObjectContext

  init(databaseName: String) {
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

  func perform(action: (NSManagedObjectContext) throws -> Void) rethrows {
    try action(context)
  }
}
