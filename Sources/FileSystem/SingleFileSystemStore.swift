import Blueprints
import Foundation

/// A single file system object store offers a convenient way to store and retrieve a single `Codable` object to the file system.
public final class SingleFileSystemStore<Object: Codable>: SingleObjectStore {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let manager = FileManager.default
  let lock = NSRecursiveLock()
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
      let data = try encoder.encode(object)
      _ = try storeURL()
      manager.createFile(atPath: try fileURL().path, contents: data)
    }
  }

  /// Returns the object saved in the store
  /// - Returns: object saved in the store. `nil` if no object is saved in store.
  public func object() -> Object? {
    do {
      let path = try fileURL().path
      guard let data = manager.contents(atPath: path) else { return nil }
      return try decoder.decode(Object.self, from: data)
    } catch {
      logger.log(error)
      return nil
    }
  }

  /// Removes any saved object in the store.
  /// - Throws error: any errors that might occur if the object was not removed.
  public func remove() throws {
    try sync {
      let path = try storeURL().path
      try manager.removeItem(atPath: path)
    }
  }
}

// MARK: - Helpers

extension SingleFileSystemStore {
  func sync(action: () throws -> Void) rethrows {
    lock.lock()
    try action()
    lock.unlock()
  }

  func storeURL() throws -> URL {
    let url = try manager
      .url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appendingPathComponent("Stores", isDirectory: true)
      .appendingPathComponent("SingleObject", isDirectory: true)
      .appendingPathComponent(uniqueIdentifier, isDirectory: true)
    if manager.fileExists(atPath: url.path) == false {
      try manager.createDirectory(atPath: url.path, withIntermediateDirectories: true)
    }
    return url
  }

  func fileURL() throws -> URL {
    return try storeURL()
      .appendingPathComponent("object")
      .appendingPathExtension("json")
  }
}

