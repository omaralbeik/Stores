// swift-tools-version:5.4

import PackageDescription

let package = Package(
  name: "Stores",
  platforms: [
    .iOS(.v13),
    .macOS(.v10_15),
    .tvOS(.v13),
    .watchOS(.v6)
  ],
  products: [
    .library(name: "Stores", targets: ["Stores"]),
    .library(name: "Blueprints", targets: ["Blueprints"]),
    .library(name: "UserDefaultsStore", targets: ["UserDefaultsStore"]),
    .library(name: "FileSystemStore", targets: ["FileSystemStore"]),
    .library(name: "CoreDataStore", targets: ["CoreDataStore"]),
    .library(name: "KeychainStore", targets: ["KeychainStore"]),
    .library(name: "StoresTestUtils", targets: ["TestUtils"]),
  ],
  targets: [
    // MARK: - Stores
    .target(
      name: "Stores",
      dependencies: [
        "Blueprints",
        "UserDefaultsStore",
        "FileSystemStore",
        "CoreDataStore",
        "KeychainStore"
      ],
      path: "Sources/Stores"
    ),
    // MARK: - Blueprints
    .target(
      name: "Blueprints",
      path: "Sources/Blueprints"
    ),
    .testTarget(
      name: "BlueprintsTests",
      dependencies: [
        "Blueprints",
        "TestUtils"
      ],
      path: "Tests/Blueprints"
    ),
    // MARK: - UserDefaults
    .target(
      name: "UserDefaultsStore",
      dependencies: [
        "Blueprints"
      ],
      path: "Sources/UserDefaults"
    ),
    .testTarget(
      name: "UserDefaultsStoreTests",
      dependencies: [
        "UserDefaultsStore",
        "TestUtils"
      ],
      path: "Tests/UserDefaults"
    ),
    // MARK: - FileSystem
    .target(
      name: "FileSystemStore",
      dependencies: [
        "Blueprints"
      ],
      path: "Sources/FileSystem"
    ),
    .testTarget(
      name: "FileSystemStoreTests",
      dependencies: [
        "FileSystemStore",
        "TestUtils"
      ],
      path: "Tests/FileSystem"
    ),
    // MARK: - CoreData
    .target(
      name: "CoreDataStore",
      dependencies: [
        "Blueprints",
      ],
      path: "Sources/CoreData"
    ),
    .testTarget(
      name: "CoreDataStoreTests",
      dependencies: [
        "CoreDataStore",
        "TestUtils",
      ],
      path: "Tests/CoreData"
    ),
    // MARK: - Keychain
    .target(
      name: "KeychainStore",
      dependencies: [
        "Blueprints",
      ],
      path: "Sources/Keychain"
    ),
    .testTarget(
      name: "KeychainStoreTests",
      dependencies: [
        "KeychainStore",
        "TestUtils",
      ],
      path: "Tests/Keychain"
    ),
    // MARK: - TestUtils
    .target(
      name: "TestUtils",
      dependencies: [
        "Blueprints"
      ],
      path: "Tests/Utils"
    ),
  ]
)
