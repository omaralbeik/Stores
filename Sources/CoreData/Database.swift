#if canImport(CoreData)

import CoreData
import Foundation

private final class Container: NSPersistentContainer {
  override class func defaultDirectoryURL() -> URL {
    super.defaultDirectoryURL().appendingPathComponent("CoreDataStore")
  }
}

final class Database {
  let context: NSManagedObjectContext

  init(name: String) {
    let container = Container(name: name, managedObjectModel: Self.entityModel)
    container.loadPersistentStores { _, error in
      if let error = error {
        preconditionFailure(
          "Failed to load store with error: \(error.localizedDescription)."
        )
      }
    }
    context = container.viewContext
  }

  static let entityModel: NSManagedObjectModel = {
    let entity = NSEntityDescription()
    entity.name = "Entity"
    entity.managedObjectClassName = "Entity"

    let idAttribute = NSAttributeDescription()
    idAttribute.name = "id"
    idAttribute.attributeType = .stringAttributeType
    idAttribute.isOptional = false
    entity.properties.append(idAttribute)

    let dataAttribute = NSAttributeDescription()
    dataAttribute.name = "data"
    dataAttribute.attributeType = .binaryDataAttributeType
    dataAttribute.isOptional = false
    entity.properties.append(dataAttribute)

    let lastUpdatedAttribute = NSAttributeDescription()
    lastUpdatedAttribute.name = "lastUpdated"
    lastUpdatedAttribute.attributeType = .dateAttributeType
    lastUpdatedAttribute.isOptional = false
    entity.properties.append(lastUpdatedAttribute)

    let model = NSManagedObjectModel()
    model.entities = [entity]

    return model
  }()

  let entitiesFetchRequest: () -> NSFetchRequest<Entity> = {
    let request = NSFetchRequest<Entity>(entityName: "Entity")
    request.sortDescriptors = [
      .init(key: "lastUpdated", ascending: true),
    ]
    return request
  }

  let entityFetchRequest: (String) -> NSFetchRequest<Entity> = { id in
    let request = NSFetchRequest<Entity>(entityName: "Entity")
    request.predicate = NSPredicate(format: "id == %@", id)
    return request
  }
}

#endif
