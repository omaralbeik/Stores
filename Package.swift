// swift-tools-version: 5.6

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
    .target(
      name: "Blueprints",
      path: "Sources/Blueprints"
    ),
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
    .target(
      name: "CoreDataStore",
      dependencies: [
        "Blueprints",
      ],
      path: "Sources/CoreData",
      resources: [.process("Resources")]
    ),
    .testTarget(
      name: "CoreDataStoreTests",
      dependencies: [
        "CoreDataStore",
        "TestUtils",
      ],
      path: "Tests/CoreData"
    ),
    .target(
      name: "TestUtils",
      dependencies: [
        "Blueprints"
      ],
      path: "Tests/Utils"
    ),
  ]
)
