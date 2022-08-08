import CoreData

@objc(Entity)
final class Entity: NSManagedObject {
  @NSManaged var id: String?
  @NSManaged var data: Data?
  @NSManaged var lastUpdated: Date?

  override var description: String {
    return "Entity"
  }

  @nonobjc
  class func fetchRequest() -> NSFetchRequest<Entity> {
    let request = NSFetchRequest<Entity>(entityName: "Entity")
    request.sortDescriptors = [
      .init(key: "lastUpdated", ascending: true)
    ]
    return request
  }

  @nonobjc
  class func fetchRequest(id: String) -> NSFetchRequest<Entity> {
    let request = fetchRequest()
    request.predicate = NSPredicate(format: "id == %@", id)
    return request
  }
}
