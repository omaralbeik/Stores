import Foundation

enum StoresError: LocalizedError {
  case invalid

  var errorDescription: String? {
    return "Invalid."
  }
}
