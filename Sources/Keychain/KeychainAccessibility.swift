import Foundation

/// An object representing keychain accessibility level.
public struct KeychainAccessibility: Equatable {
  let attribute: CFString

  /// The data in the keychain item cannot be accessed after a restart until the device has been unlocked
  /// once by the user.
  public static let afterFirstUnlock = Self(
    attribute: kSecAttrAccessibleAfterFirstUnlock
  )

  /// The data in the keychain item can be accessed only while the device is unlocked by the user.
  public static let whenUnlocked = Self(
    attribute: kSecAttrAccessibleWhenUnlocked
  )

  /// The data in the keychain item can be accessed only while the device is unlocked by the user.
  public static let whenUnlockedThisDeviceOnly = Self(
    attribute: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
  )

  /// The data in the keychain can only be accessed when the device is unlocked.
  /// Only available if a passcode is set on the device.
  public static let whenPasscodeSetThisDeviceOnly = Self(
    attribute: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
  )

  /// The data in the keychain item cannot be accessed after a restart until the device has been
  /// unlocked once by the user.
  public static let afterFirstUnlockThisDeviceOnly = Self(
    attribute: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
  )
}
