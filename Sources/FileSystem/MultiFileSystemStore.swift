import Blueprints
import Foundation

/// A multi object file system store offers a convenient way to store and retrieve a collection of `Codable` and `Identifiable` objects to the file system.
public final class MultiFileSystemStore<Object: Codable & Identifiable>: MultiObjectStore {
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let manager = FileManager.default
  private let lock = NSRecursiveLock()

  let logger = Logger()

  /// Store's unique identifier.
  ///
  /// **Warning**: Never use the same identifier for multiple stores with different object types, doing this might cause stores to have corrupted data.
  public let uniqueIdentifier: String

  /// Directory where the store folder is created.
  public let directory: FileManager.SearchPathDirectory

  /// Initialize store with given identifier.
  ///
  /// **Warning**: Never use the same identifier for multiple stores with different object types, doing this might cause stores to have corrupted data.
  ///
  /// - Parameter uniqueIdentifier: store's unique identifier.
  /// - Parameter directory: directory where the store folder is created. Defaults to `.applicationSupportDirectory`
  required public init(
    uniqueIdentifier: String,
    directory: FileManager.SearchPathDirectory = .applicationSupportDirectory
  ) {
    self.uniqueIdentifier = uniqueIdentifier
    self.directory = directory
  }

  // MARK: - Store

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any encoding errors.
  public func save(_ object: Object) throws {
    try sync {
      let newURL = try url(for: object)
      let data = try encoder.encode(object)
      try manager.createDirectory(at: newURL, withIntermediateDirectories: true)
      manager.createFile(atPath: newURL.path, contents: data)
    }
  }

  /// The number of all objects stored in store.
  public var objectsCount: Int {
    do {
      let storeURL = try storeURL()
      let items = try manager.contentsOfDirectory(
        at: storeURL,
        includingPropertiesForKeys: nil,
        options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants]
      )
      return items.count
    } catch {
      logger.log(error)
      return 0
    }
  }

  /// Wether the store contains a saved object with the given id.
  public func containsObject(withId id: Object.ID) -> Bool {
    do {
      let path = try url(for: id).path
      return manager.fileExists(atPath: path)
    } catch {
      logger.log(error)
      return false
    }
  }

  /// Returns an object for the given id, or `nil` if no object is found.
  /// - Parameter id: object id.
  /// - Returns: object with the given id, or`nil` if no object with the given id is found.
  public func object(withId id: Object.ID) -> Object? {
    do {
      let path = try url(for: id).path
      guard let data = manager.contents(atPath: path) else { return nil }
      return try decoder.decode(Object.self, from: data)
    } catch {
      logger.log(error)
      return nil
    }
  }

  /// Returns all objects in the store.
  /// - Returns: collection containing all objects stored in store.
  public func allObjects() -> [Object] {
    do {
      let storePath = try storeURL().path
      return try manager.contentsOfDirectory(atPath: storePath).compactMap(object(atPath:))
    } catch {
      logger.log(error)
      return []
    }
  }

  /// Removes object with the given id —if found—.
  /// - Parameter id: id for the object to be deleted.
  public func remove(withId id: Object.ID) {
    sync {
      do {
        let path = try url(for: id).path
        if manager.fileExists(atPath: path) {
          try manager.removeItem(atPath: path)
        }
      } catch {
        logger.log(error)
      }
    }
  }

  /// Removes all objects in store.
  public func removeAll() {
    sync {
      do {
        let storePath = try storeURL().path
        if manager.fileExists(atPath: storePath) {
          try manager.removeItem(atPath: storePath)
        }
      } catch {
        logger.log(error)
      }
    }
  }
}

// MARK: - Helpers

private extension MultiFileSystemStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    try action()
    lock.unlock()
  }

  func object(atPath path: String) throws -> Object? {
    guard let data = manager.contents(atPath: path) else { return nil }
    return try decoder.decode(Object.self, from: data)
  }

  func storeURL() throws -> URL {
    return try manager
      .url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appendingPathComponent("Stores", isDirectory: true)
      .appendingPathComponent("MultiObjects", isDirectory: true)
      .appendingPathComponent(uniqueIdentifier, isDirectory: true)
  }

  func url(for id: Object.ID) throws -> URL {
    return try storeURL()
      .appendingPathComponent("\(id)")
      .appendingPathExtension("json")
  }

  func url(for object: Object) throws -> URL {
    return try url(for: object.id)
  }
}
