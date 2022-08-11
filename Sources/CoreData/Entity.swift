import CoreData
import Foundation

@objc(Entity)
final class Entity: NSManagedObject {
  @NSManaged var id: String?
  @NSManaged var data: Data?
  @NSManaged var lastUpdated: Date?
}
