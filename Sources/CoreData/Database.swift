import CoreData
import Foundation

final class Database {
  let context: NSManagedObjectContext

  init(name: String) {
    let modelURL = Bundle.module.url(
      forResource: "Models",
      withExtension: "momd"
    )!
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
