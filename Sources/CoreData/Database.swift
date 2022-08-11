import CoreData
import Foundation

private final class Container: NSPersistentContainer {
  override class func defaultDirectoryURL() -> URL {
    super.defaultDirectoryURL().appendingPathComponent("CoreDataStore")
  }
}

final class Database {
  static let entityModel: NSManagedObjectModel = {
    let entity = NSEntityDescription()
    entity.name = "Entity"
    entity.managedObjectClassName = "Entity"

    let idAttribute = NSAttributeDescription()
    idAttribute.name = "id"
    idAttribute.type = .string
    idAttribute.isOptional = false
    entity.properties.append(idAttribute)

    let dataAttribute = NSAttributeDescription()
    dataAttribute.name = "data"
    dataAttribute.type = .binaryData
    dataAttribute.isOptional = false
    entity.properties.append(dataAttribute)

    let lastUpdatedAttribute = NSAttributeDescription()
    lastUpdatedAttribute.name = "lastUpdated"
    lastUpdatedAttribute.type = .date
    lastUpdatedAttribute.isOptional = false
    entity.properties.append(lastUpdatedAttribute)

    let model = NSManagedObjectModel()
    model.entities = [entity]

    return model
  }()
  
  let context: NSManagedObjectContext

  init(name: String) {
    let container = Container(name: name, managedObjectModel: Self.entityModel)
    container.loadPersistentStores { _, error in
      if let error = error {
        preconditionFailure("Failed to load store with error: \(error).")
      }
    }
    context = container.viewContext
  }
}
