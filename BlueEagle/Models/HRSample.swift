import Foundation

struct HRSample: Codable {
  var rate: Double = 0.0
  var at: Date = Date()

  func toJson() -> String {
    guard let json = try? JSONEncoder().encode(self)
    else {
      return "{\"rate\": \(rate), \"at\": \(at)}"
    }
    return String(data: json, encoding: .utf8)!
  }
}
