import Foundation

public struct User: Codable, Identifiable, Hashable {
  public init(
    id: Int,
    firstName: String,
    lastName: String,
    age: Double
  ) {
    self.id = id
    self.firstName = firstName
    self.lastName = lastName
    self.age = age
  }

  public let id: Int
  public var firstName: String
  public var lastName: String
  public var age: Double
}

extension User: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }
}

extension User: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.id < rhs.id
  }
}

extension User: CustomStringConvertible {
  public var description: String {
    return firstName
  }
}

public extension User {
  static let john = Self(id: 1, firstName: "John", lastName: "Appleseed", age: 21.5)
  static let johnson = Self(id: 2, firstName: "Johnson", lastName: "Smith", age: 26.3)
  static let james = Self(id: 3, firstName: "James", lastName: "Robert", age: 14)
  static let invalid = Self(id: 4, firstName: "", lastName: "", age: .nan)
}
