import Foundation
import SwiftUI

enum Sex: String, Equatable, CaseIterable, Codable {
  case undeclared = "undeclared"
  case female = "female"
  case male = "male"
}

@Observable
class User: ObservableObject, EventBusObserver {

  static let current = User()

  let observing: [Selector: [NSNotification.Name]] = [
    #selector(heartRateMonitorValueUpdated(notification:)): [.HeartRateMonitorValueUpdated]
  ]

  @ObservationIgnored @AppStorage("sex") var sex: Sex = .undeclared
  @ObservationIgnored @AppStorage("weight") var weight: Int = 70
  @ObservationIgnored @AppStorage("height") var height: Int = 170
  @ObservationIgnored @AppStorage("storedRestingHeartRate") var storedRestingHeartRate: Int = 50
  @ObservationIgnored @AppStorage("heartRateMonitor") var heartRateMonitor: String = ""
  @ObservationIgnored @AppStorage("storedBirthdate") private var storedBirthdate = Date.now
    .timeIntervalSinceReferenceDate

  var heartRate: Double = 0

  init() {
    EventBus.addObserver(self)
  }
    
  @objc private func heartRateMonitorValueUpdated(notification: Notification) {
    let event = notification.object as! PeripheralValueUpdatedEvent
    self.heartRate = event.sample
  }
    
  var restingHeartRate: Double {
    get { return Double(storedRestingHeartRate) }
    set { storedRestingHeartRate = Int(newValue)}
  }
    
  var birthdate: Date {
    get { return Date(timeIntervalSinceReferenceDate: storedBirthdate) }
    set {
      storedBirthdate = newValue.timeIntervalSinceReferenceDate
    }
  }

  var age: Double {
    Double(Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year!)
  }

  // Tanaka, Monahan, & Seals Formula
  var maxHeartRate: Double {
    return round(208 - age * 0.7)
  }

  var heartRateReserve: Double {
    return maxHeartRate - restingHeartRate
  }

  var zone: TrainingZone {
    func kernel(_ bound: Double) -> Double {
      return round(heartRateReserve * bound + restingHeartRate)
    }

    return TrainingZones.first { zone in
      return zone.range(kernel).contains(heartRate)
    }!
  }

  var exertion: Double {
    return (heartRate - restingHeartRate) / heartRateReserve
  }
}
