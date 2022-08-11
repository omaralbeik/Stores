// swift-tools-version: 5.5

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
  ],
  dependencies: [],
  targets: [
    // MARK: - Stores
    .target(
      name: "Stores",
      dependencies: [
        "Blueprints",
        "UserDefaultsStore",
        "FileSystemStore",
        "CoreDataStore"
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
    // MARK: - UserDefaultsStore
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
