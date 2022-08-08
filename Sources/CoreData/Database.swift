import CoreData

// https://betterprogramming.pub/use-coredata-from-an-spm-package-e82c465d5d02

final class Database {
  let context: NSManagedObjectContext

  init(name: String) {
    let modelURL = Bundle.module.url(forResource: "Models", withExtension: "momd")!
    let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
    let container = NSPersistentContainer(
      name: name,
      managedObjectModel: managedObjectModel
    )
    container.loadPersistentStores { _, error in
      if let error = error {
        preconditionFailure("Failed to load store with error: \(error).")
      }
    }
    context = container.viewContext
  }
}
