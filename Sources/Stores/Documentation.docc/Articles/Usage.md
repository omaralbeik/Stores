# Usage

How to use Stores in your project

---

Let's say you have a `User` struct defined as below:

```swift
struct User: Codable {
    let id: Int
    let name: String
}
```

Here's how you store it using Stores:

## 1. Conform to `Identifiable`

This is required to make the store associate an object with its id.

```swift
extension User: Identifiable {}
```

The property `id` can be on any `Hashable` type. [Read more](https://developer.apple.com/documentation/swift/identifiable).

## 2. Create a store

Stores comes pre-equipped with the following stores:

#### a. UserDefaults

- ``MultiUserDefaultsStore``
- ``SingleUserDefaultsStore``

```swift
// Store for multiple objects
let store = MultiUserDefaultsStore<User>(identifier: "users")

// Store for a single object
let store = SingleUserDefaultsStore<User>(identifier: "users")
```

#### b. FileSystem

- ``MultiFileSystemStore``
- ``SingleFileSystemStore``

```swift
// Store for multiple objects
let store = MultiFileSystemStore<User>(identifier: "users")

// Store for a single object
let store = SingleFileSystemStore<User>(identifier: "users")
```

#### c. CoreData

- ``MultiCoreDataStore``
- ``SingleCoreDataStore``

```swift
// Store for multiple objects
let store = MultiCoreDataStore<User>(identifier: "users")

// Store for a single object
let store = SingleCoreDataStore<User>(identifier: "users")
```

#### d. Keychain

- ``MultiKeychainStore``
- ``SingleKeychainStore``

```swift
// Store for multiple objects
let store = MultiKeychainStore<User>(identifier: "users")

// Store for a single object
let store = SingleKeychainStore<User>(identifier: "users")
```

#### e. Fakes (for testing)

```swift
// Store for multiple objects
let store = MultiObjectStoreFake<User>()

// Store for a single object
let store = SingleObjectStoreFake<User>()
```

You can create a custom store by implementing the protocols in [`Blueprints`](https://github.com/omaralbeik/Stores/tree/main/Sources/Blueprints)

#### f. Realm

```swift
// Store for multiple objects
final class MultiRealmStore<Object: Codable & Identifiable>: MultiObjectStore {
    // ...
}

// Store for a single object
final class SingleRealmStore<Object: Codable>: SingleObjectStore {
    // ...
}
```

#### g. SQLite

```swift
// Store for multiple objects
final class MultiSQLiteStore<Object: Codable & Identifiable>: MultiObjectStore {
    // ...
}

// Store for a single object
final class SingleSQLiteStore<Object: Codable>: SingleObjectStore {
    // ...
}
```

## 3. Inject the store

Assuming we have a view model that uses a store to fetch data:

```swift
struct UsersViewModel {
    let store: AnyMultiObjectStore<User>
}
```

Inject the appropriate store implementation:

```swift
let coreDataStore = MultiCoreDataStore<User>(databaseName: "users")
let prodViewModel = UsersViewModel(store: coreDataStore.eraseToAnyStore())
```

or:

```swift
let fakeStore = MultiObjectStoreFake<User>()
let testViewModel = UsersViewModel(store: fakeStore.eraseToAnyStore())
```

## 4. Save, retrieve, update, or remove objects

```swift
let john = User(id: 1, name: "John Appleseed")

// Save an object to a store
try store.save(john)

// Save an array of objects to a store
try store.save([jane, steve, jessica])

// Get an object from store
let user = store.object(withId: 1)

// Get an array of object in store
let users = store.objects(withIds: [1, 2, 3])

// Get an array of all objects in store
let allUsers = store.allObjects()

// Check if store has an object
print(store.containsObject(withId: 10)) // false

// Remove an object from a store
try store.remove(withId: 1)

// Remove multiple objects from a store
try store.remove(withIds: [1, 2, 3])

// Remove all objects in a store
try store.removeAll()
```
