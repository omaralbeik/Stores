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
}
