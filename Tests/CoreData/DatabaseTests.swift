#if canImport(CoreData)

@testable import CoreDataStore

import CoreData
import Foundation
import XCTest

final class DatabaseTests: XCTestCase {
  func testModel() {
    let model = Database.entityModel
    XCTAssertEqual(model.entities.count, 1)

    let entity = model.entities[0]
    let properties = entity.properties.compactMap {
      $0 as? NSAttributeDescription
    }
    XCTAssertEqual(properties.count, 3)

    let sortedProperties = properties.sorted { $0.name < $1.name }

    XCTAssertEqual(sortedProperties[0].name, "data")
    XCTAssertEqual(sortedProperties[0].attributeType, .binaryDataAttributeType)
    XCTAssertFalse(sortedProperties[0].isOptional)

    XCTAssertEqual(sortedProperties[1].name, "id")
    XCTAssertEqual(sortedProperties[1].attributeType, .stringAttributeType)
    XCTAssertFalse(sortedProperties[1].isOptional)

    XCTAssertEqual(sortedProperties[2].name, "lastUpdated")
    XCTAssertEqual(sortedProperties[2].attributeType, .dateAttributeType)
    XCTAssertFalse(sortedProperties[2].isOptional)
  }

  func testEntitiesFetchRequest() {
    let database = Database(name: "test", container: Container(name: "test"))
    let request = database.entitiesFetchRequest()
    XCTAssertEqual(request.entityName, "Entity")
    XCTAssertEqual(
      request.sortDescriptors,
      [.init(key: "lastUpdated", ascending: true)]
    )
  }

  func testEntityFetchRequest() {
    let database = Database(name: "test", container: Container(name: "test"))
    let id = "test-id"
    let request = database.entityFetchRequest(id)
    XCTAssertEqual(request.entityName, "Entity")
    XCTAssertEqual(
      request.predicate,
      NSPredicate(format: "id == %@", id)
    )
    XCTAssertEqual(request.fetchLimit, 1)
  }
}

final class TestContainer: NSPersistentContainer {
  override class func defaultDirectoryURL() -> URL {
    super.defaultDirectoryURL().appendingPathComponent("Test")
  }
}

#endif
