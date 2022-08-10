import Foundation

struct User: Codable, Identifiable, Hashable {
  init(
    id: Int,
    firstName: String,
    lastName: String = "",
    age: Double = 30
  ) {
    self.id = id
    self.firstName = firstName
    self.lastName = lastName
    self.age = age
  }

  let id: Int
  var firstName: String
  var lastName: String
  var age: Double
}

extension User: Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.id == rhs.id
  }
}

extension User: Comparable {
  static func < (lhs: Self, rhs: Self) -> Bool {
    lhs.id < rhs.id
  }
}

extension User: CustomStringConvertible {
  var description: String {
    return firstName
  }
}

extension User {
  static let ahmad = Self(id: 1, firstName: "Ahmad")
  static let dalia = Self(id: 2, firstName: "Dalia")
  static let kareem = Self(id: 3, firstName: "Kareem")

  static let invalid = Self(id: 4, firstName: "", age: .nan)
}
