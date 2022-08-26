import Foundation

/// A helper class used to log errors to console and perform actions that might throw an error.
public final class Logger {
  /// Create a new logger.
  public init() {}

  /// Last console output.
  public private(set) var lastOutput: String?

  var error: Error?

  /// Log an error to console.
  /// - Parameters:
  ///   - error: error to be logged to console.
  ///   - fileName: file name of where the error occurred.
  ///   - functionName: function name of where the error occurred.
  /// - Returns: the string that was printed to console.
  @discardableResult public func log(
    _ error: Error,
    fileName: String = #file,
    functionName: String = #function
  ) -> String {
    let file = fileName
      .split(separator: "/")
      .last?
      .replacingOccurrences(of: ".swift", with: "") ?? fileName
    let location = "`\(file).\(functionName)`"
    let errorDescription = error.localizedDescription
    let message = "An error occurred in \(location). Error: \(errorDescription)"
    #if DEBUG
    print(message)
    #endif
    lastOutput = message
    return message
  }

  /// Perform an action and return its result.
  /// - Returns: Action to be performed.
  @discardableResult public func perform<Output>(
    _ action: @autoclosure () throws -> Output
  ) throws -> Output {
    if let error = error {
      throw error
    }
    let result = try action()
    return result
  }
}
