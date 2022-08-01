import Blueprints
import Foundation

/// A single file system object store offers a convenient way to store and retrieve a single `Codable` object to the file system.
public final class SingleFileSystemStore<Object: Codable>: SingleObjectStore {
  private let encoder = JSONEncoder()
  private let decoder = JSONDecoder()
  private let manager = FileManager.default

  /// Store's unique identifier.
  ///
  /// **Warning**: Never use the same identifier for two -or more- different stores.
  public let uniqueIdentifier: String

  /// Directory where the store folder is created.
  public let directory: FileManager.SearchPathDirectory

  /// Initialize store with given identifier.
  ///
  /// **Warning**: Never use the same identifier for two -or more- different stores.
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
    let data = try encoder.encode(object)
    let url = try storeURL()
    try manager.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
    manager.createFile(atPath: try fileURL().path, contents: data, attributes: nil)
  }

  /// Returns the object saved in the store
  /// - Returns: object saved in the store. `nil` if no object is saved in store.
  public func object() -> Object? {
    guard let path = try? fileURL().path else { return nil }
    guard let data = manager.contents(atPath: path) else { return nil }
    return try? decoder.decode(Object.self, from: data)
  }

  /// Removes any saved object in the store.
  public func remove() {
    do {
      let url = try storeURL()
      guard manager.fileExists(atPath: url.path) else { return }
      try manager.removeItem(at: url)
    } catch {
      fatalError("Unable to remove object at store: \(uniqueIdentifier): \(error.localizedDescription)")
    }
  }
}

// MARK: - Helpers

private extension SingleFileSystemStore {
  func storeURL() throws -> URL {
    return try manager
      .url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appendingPathComponent("Stores", isDirectory: true)
      .appendingPathComponent("SingleObjects", isDirectory: true)
      .appendingPathComponent(uniqueIdentifier, isDirectory: true)
  }

  func fileURL() throws -> URL {
    return try storeURL()
      .appendingPathComponent("object")
      .appendingPathExtension("json")
  }
}

