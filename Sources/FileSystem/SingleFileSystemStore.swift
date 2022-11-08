import Blueprints
import Foundation

/// The single file system object store is an implementation of `SingleObjectStore` that offers a
/// convenient and type-safe way to store and retrieve a single `Codable` object by saving it as a json file
/// using the file system.
///
/// > Thread safety: This is a thread-safe class.
public final class SingleFileSystemStore<Object: Codable>: SingleObjectStore {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()
  let manager = FileManager.default
  let lock = NSRecursiveLock()
  let logger = Logger()

  /// Directory where the store folder is created.
  public let directory: FileManager.SearchPathDirectory

  /// Store's path.
  ///
  /// > Note: This is used to create the directory where the file is saved:
  /// >
  /// > `{directory}/Stores/SingleObject/{path}/object.json`
  ///
  /// > Important: Never use the same path for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  public let path: String

  /// Initialize store with given directory and path.
  ///
  /// > Important: Never use the same path for multiple stores with different object types,
  /// doing this might cause stores to have corrupted data.
  ///
  /// - Parameter directory: directory where the store folder is created.
  /// Defaults to `.applicationSupportDirectory`
  /// - Parameter path: store's path.
  ///
  /// > Note: Directory and path are used to create the directory where the file is saved:
  /// >
  /// > `{directory}/Stores/SingleObject/{path}/object.json`
  /// >
  /// > Creating a store is a fairly cheap operation, you can create multiple instances of the same store
  /// with a same directory and path.
  public required init(
    directory: FileManager.SearchPathDirectory = .applicationSupportDirectory,
    path: String
  ) {
    self.directory = directory
    self.path = path
  }

  // MARK: - Deprecated

  /// Deprecated: Store's unique identifier.
  @available(*, deprecated, renamed: "name")
  public var identifier: String { path }

  /// Deprecated: Initialize store with given identifier and directory.
  @available(*, deprecated, renamed: "init(directory:name:)")
  public required init(
    identifier: String,
    directory: FileManager.SearchPathDirectory = .applicationSupportDirectory
  ) {
    self.directory = directory
    self.path = identifier
  }

  // MARK: - SingleObjectStore

  /// Saves an object to store.
  /// - Parameter object: object to be saved.
  /// - Throws error: any error that might occur during the save operation.
  public func save(_ object: Object) throws {
    try sync {
      let data = try encoder.encode(object)
      _ = try storeURL()
      manager.createFile(atPath: try fileURL().path, contents: data)
    }
  }

  /// Returns the object saved in the store
  ///
  /// > Note: Errors thrown out by file manager during reading files will be ignored and logged out to console
  /// in DEBUG.
  ///
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
    defer { lock.unlock() }
    try action()
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
      .appendingPathComponent("SingleObject", isDirectory: true)
      .appendingPathComponent(path, isDirectory: true)
    if manager.fileExists(atPath: url.path) == false {
      try manager.createDirectory(
        atPath: url.path,
        withIntermediateDirectories: true
      )
    }
    return url
  }

  func fileURL() throws -> URL {
    return try storeURL()
      .appendingPathComponent("object")
      .appendingPathExtension("json")
  }
}
