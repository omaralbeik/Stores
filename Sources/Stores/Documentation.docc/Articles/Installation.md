# Installation

How to add Stores to your project

---

You can add Stores to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Add Packages...**
2. Enter "**https://github.com/omaralbeik/Stores**" into the package repository URL text field
3. Depending on what you want to use Stores for, add the following target(s) to your app:
    - `Stores`: the entire library with all stores.
    - `UserDefaultsStore`: use User Defaults to persist data.
    - `FileSystemStore`: persist data by saving it to the file system.
    - `CoreDataStore`: use a Core Data database to persist data.
    - `KeychainStore`: persist data securely in the Keychain.
    - `Blueprints`: protocols only, this is a good option if you do not want to use any of the provided stores and build yours.
    - `StoresTestUtils` to use the fakes in your tests target.
