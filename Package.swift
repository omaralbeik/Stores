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
    .library(name: "SQLiteStore", targets: ["SQLiteStore"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/stephencelis/SQLite.swift.git",
      from: "0.13.3"
    )
  ],
  targets: [
    .target(
      name: "Stores",
      dependencies: [
        "Blueprints",
        "UserDefaultsStore",
        "FileSystemStore",
        "SQLiteStore"
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
      name: "SQLiteStore",
      dependencies: [
        "Blueprints",
        .product(name: "SQLite", package: "SQLite.swift")
      ],
      path: "Sources/SQLite"
    ),
    .testTarget(
      name: "SQLiteStoreTests",
      dependencies: [
        "SQLiteStore",
        "TestUtils",
        .product(name: "SQLite", package: "SQLite.swift")
      ],
      path: "Tests/SQLite"
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
