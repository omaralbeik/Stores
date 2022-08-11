import Foundation

final class Logger {
  init(printEnabled: Bool = true) {
    self.printEnabled = printEnabled
  }

  var printEnabled: Bool
  var lastOutput: String?

  @discardableResult
  func log(
    _ error: Error,
    fileName: String = #file,
    functionName: String = #function
  ) -> String {
    let file = fileName
      .split(separator: "/")
      .last?
      .replacingOccurrences(of: ".swift", with: "") ?? ""
    let location = "`\(file).\(functionName)`"
    let errorDescription = error.localizedDescription
    let message = "An error occurred in \(location). Error: \(errorDescription)"
    if printEnabled {
      #if DEBUG
      print(message)
      #endif
    }
    lastOutput = message
    return message
  }
}
