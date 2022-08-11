@testable import CoreDataStore

import Foundation
import CoreData
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

    XCTAssertEqual(properties[0].name, "id")
    XCTAssertEqual(properties[0].attributeType, .stringAttributeType)
    XCTAssertFalse(properties[0].isOptional)

    XCTAssertEqual(properties[1].name, "data")
    XCTAssertEqual(properties[1].attributeType, .binaryDataAttributeType)
    XCTAssertFalse(properties[1].isOptional)

    XCTAssertEqual(properties[2].name, "lastUpdated")
    XCTAssertEqual(properties[2].attributeType, .dateAttributeType)
    XCTAssertFalse(properties[2].isOptional)
  }
}
