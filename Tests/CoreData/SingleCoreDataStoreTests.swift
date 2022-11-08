#if canImport(CoreData)

@testable import CoreDataStore
@testable import TestUtils

import CoreData
import Foundation
import XCTest

final class SingleCoreDataStoreTests: XCTestCase {
  private var store: SingleCoreDataStore<User>?

  override func tearDownWithError() throws {
    try store?.remove()
  }

  func testCreateStore() {
    let databaseName = UUID().uuidString
    let store = createFreshUserStore(databaseName: databaseName)
    XCTAssertEqual(store.databaseName, databaseName)
  }


  func testCreateStoreWithCustomContainer() {
    let databaseName = UUID().uuidString
    let store = SingleCoreDataStore<User>(databaseName: databaseName) { model in
      TestContainer(name: databaseName, managedObjectModel: model)
    }
    self.store = store

    let path = store.databaseURL?.pathComponents.suffix(2).joined(separator: "/")
    let expectedPath = "Test/\(databaseName).sqlite"
    XCTAssertEqual(path, expectedPath)
  }

  func testDatabaseURL() {
    let store = createFreshUserStore()
    let path = store.databaseURL?.pathComponents.suffix(2)
    XCTAssertEqual(path, ["CoreDataStore", "\(store.databaseName).sqlite"])
  }

  func testSaveObject() throws {
    let store = createFreshUserStore()
    try store.save(.ahmad)
    XCTAssertEqual(store.object(), .ahmad)

    let user: User? = .kareem
    try store.save(user)
    XCTAssertEqual(store.object(), .kareem)

    try store.save(nil)
    XCTAssertNil(store.object())
  }

  func testSaveInvalidObject() {
    let store = createFreshUserStore()
    XCTAssertThrowsError(try store.save(User.invalid))
    XCTAssertNil(store.object())
  }

  func testObject() throws {
    let store = createFreshUserStore()
    try store.save(.dalia)
    XCTAssertEqual(store.object(), .dalia)
  }

  func testObjectLogging() throws {
    let store = createFreshUserStore()
    try store.save(.ahmad)

    let request = store.database.entityFetchRequest(store.key)
    let entities = try store.database.context.fetch(request)
    entities[0].data = "{]".data(using: .utf8)!
    try store.database.context.save()

    XCTAssertNil(store.object())
    XCTAssertEqual(
      store.logger.lastOutput,
      """
      An error occurred in `SingleCoreDataStore.object()`. \
      Error: The data couldn’t be read because it isn’t in the correct format.
      """
    )
  }
}

// MARK: - Helpers

private extension SingleCoreDataStoreTests {
  func createFreshUserStore(
    databaseName: String = "user"
  ) -> SingleCoreDataStore<User> {
    let store = SingleCoreDataStore<User>(databaseName: databaseName)
    XCTAssertNoThrow(try store.remove())
    self.store = store
    return store
  }
}

#endif
