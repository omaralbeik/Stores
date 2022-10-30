import Blueprints
import Foundation

/// The multi object file system store is an implementation of `MultiObjectStore` that offers a
/// convenient and type-safe way to store and retrieve a collection of `Codable` and `Identifiable`
/// objects as json files using the file system.
///
/// > Thread safety: This is a thread-safe class.
public final class MultiFileSystemStore<
  Object: Codable & Identifiable
>: MultiObjectStore {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let manager = FileManager.default
  let lock = NSRecursiveLock()
  let logger = Logger()

  /// Store's unique identifier.
  ///
  /// > Important: Never use the same identifier for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  public let identifier: String

  /// Directory where the store folder is created.
  public let directory: FileManager.SearchPathDirectory

  /// Initialize store with given identifier.
  ///
  /// > Important: Never use the same identifier for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  ///
  /// - Parameter identifier: store's unique identifier.
  /// - Parameter directory: directory where the store folder is created.
  /// Defaults to `.applicationSupportDirectory`
  ///
  /// > Note: Creating a store is a fairly cheap operation, you can create multiple instances of the same store
  /// with a same identifier and directory.
  public required init(
    identifier: String,
    directory: FileManager.SearchPathDirectory = .applicationSupportDirectory
  ) {
    self.identifier = identifier
    self.directory = directory
  }

  // MARK: - MultiObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object) throws {
    try sync {
      _ = try storeURL().path
      let newURL = try url(forObject: object)
      let data = try encoder.encode(object)
      manager.createFile(atPath: newURL.path, contents: data)
    }
  }

  /// Saves an array of objects to store.
  /// - Parameter objects: array of objects to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ objects: [Object]) throws {
    try sync {
      let pairs = try objects.map { object -> (url: URL, data: Data) in
        let url = try url(forObject: object)
        let data = try encoder.encode(object)
        return (url, data)
      }
      pairs.forEach { pair in
        manager.createFile(atPath: pair.url.path, contents: pair.data)
      }
    }
  }

  /// The number of all objects stored in store.
  ///
  /// > Note: Errors thrown out by file manager during reading files will be ignored and logged out to console
  /// in DEBUG.
  public var objectsCount: Int {
    do {
      let storeURL = try logger.perform(storeURL())
      let items = try logger.perform(
        manager.contentsOfDirectory(
          at: storeURL,
          includingPropertiesForKeys: nil,
          options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
        )
      )
      return items.count
    } catch {
      logger.log(error)
      return 0
    }
  }

  /// Whether the store contains a saved object with the given id.
  ///
  /// > Note: Errors thrown out by file manager during reading files will be ignored and logged out to console
  /// in DEBUG.
  ///
  /// - Parameter id: object id.
  /// - Returns: true if store contains an object with the given id.
  public func containsObject(withId id: Object.ID) -> Bool {
    do {
      let path = try logger.perform(url(forObjectWithId: id).path)
      return manager.fileExists(atPath: path)
    } catch {
      logger.log(error)
      return false
    }
  }

  /// Returns an object for the given id, or `nil` if no object is found.
  ///
  /// > Note: Errors thrown out by file manager during reading files will be ignored and logged out to console
  /// in DEBUG.
  ///
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or `nil` if no object with the given id is found.
  public func object(withId id: Object.ID) -> Object? {
    do {
      let path = try url(forObjectWithId: id).path
      guard let data = manager.contents(atPath: path) else { return nil }
      return try decoder.decode(Object.self, from: data)
    } catch {
      logger.log(error)
      return nil
    }
  }

  /// Returns all objects in the store.
  ///
  /// > Note: Errors thrown out by file manager during reading files will be ignored and logged out to console
  /// in DEBUG.
  ///
  /// - Returns: collection containing all objects stored in store.
  public func allObjects() -> [Object] {
    do {
      let storePath = try logger.perform(storeURL().path)
      return try logger.perform(
        manager.contentsOfDirectory(atPath: storePath)
          .compactMap(url(forObjectPath:))
          .map(\.path)
          .compactMap {
            do {
              return try logger.perform(object(atPath: $0))
            } catch {
              logger.log(error)
              return nil
            }
          }
      )
    } catch {
      logger.log(error)
      return []
    }
  }

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withId id: Object.ID) throws {
    try sync {
      let path = try url(forObjectWithId: id).path
      if manager.fileExists(atPath: path) {
        try manager.removeItem(atPath: path)
      }
    }
  }

  /// Removes all objects in store.
  public func removeAll() throws {
    try sync {
      let storePath = try storeURL().path
      if manager.fileExists(atPath: storePath) {
        try manager.removeItem(atPath: storePath)
      }
    }
  }
}

// MARK: - Helpers

extension MultiFileSystemStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    defer { lock.unlock() }
    try action()
  }

  func object(atPath path: String) throws -> Object? {
    guard let data = manager.contents(atPath: path) else { return nil }
    return try decoder.decode(Object.self, from: data)
  }

  func storeURL() throws -> URL {
    let url = try manager
      .url(
        for: directory,
        in: .userDomainMask,
        appropriateFor: nil,
        create: true
      )
      .appendingPathComponent("Stores", isDirectory: true)
      .appendingPathComponent("MultiObjects", isDirectory: true)
      .appendingPathComponent(identifier, isDirectory: true)
    if manager.fileExists(atPath: url.path) == false {
      try manager.createDirectory(
        atPath: url.path,
        withIntermediateDirectories: true
      )
    }
    return url
  }

  func url(forObjectWithId id: Object.ID) throws -> URL {
    return try storeURL()
      .appendingPathComponent("\(id)")
      .appendingPathExtension("json")
  }

  func url(forObject object: Object) throws -> URL {
    return try url(forObjectWithId: object.id)
  }

  func url(forObjectPath objectPath: String) throws -> URL {
    return try storeURL()
      .appendingPathComponent(objectPath, isDirectory: false)
  }
}
