//
//  User.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/06/22.
//

import Foundation
import SwiftUI

enum Sex: String, Equatable, CaseIterable, Codable {
  case undeclared = "undeclared"
  case female = "female"
  case male = "male"
}

@Observable
class User: ObservableObject {

  static let current = User()

  private let observing: [Selector: NSNotification.Name] = [
    #selector(heartRateMonitorValueUpdated(notification:)): .HeartRateMonitorValueUpdated
  ]

  @objc private func heartRateMonitorValueUpdated(notification: Notification) {
    self.heartRate = notification.userInfo!["sample"] as! Int
  }

  @ObservationIgnored @AppStorage("sex") var sex: Sex = .undeclared
  @ObservationIgnored @AppStorage("weight") var weight: Int = 70
  @ObservationIgnored @AppStorage("height") var height: Int = 170
  @ObservationIgnored @AppStorage("restingHeartRate") var restingHeartRate: Int = 50
  @ObservationIgnored @AppStorage("heartRateMonitor") var heartRateMonitor: String = ""
  @ObservationIgnored @AppStorage("storedBirthdate") private var storedBirthdate = Date.now
    .timeIntervalSinceReferenceDate

  var heartRate: Int = 0

  init() {
    EventBus.registerObservers(self, observing)
  }

  var birthdate: Date {
    get { return Date(timeIntervalSinceReferenceDate: storedBirthdate) }
    set {
      storedBirthdate = newValue.timeIntervalSinceReferenceDate
    }
  }

  var age: Int {
    return Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year!
  }

  // Tanaka, Monahan, & Seals Formula
  var maxHeartRate: Int {
    return Int(round(208 - Double(age) * 0.7))
  }

  var heartRateReserve: Int {
    return maxHeartRate - restingHeartRate
  }

  var zone: TrainingZone {
    func kernel(_ bound: Double) -> Double {
      return round(Double(heartRateReserve) * bound + Double(restingHeartRate))
    }

    return TrainingZones.first { zone in
      return zone.range(kernel).contains(Double(heartRate))
    }!
  }

  var exertion: Double {
    return Double(heartRate - restingHeartRate) / Double(heartRateReserve)
  }
}
