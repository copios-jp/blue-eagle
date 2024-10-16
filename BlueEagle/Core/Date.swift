import Foundation

extension Date {
  var secondsSince1970: Int {
    Int(timeIntervalSince1970.rounded())
  }
}
