//
//  HRSample.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/28.
//

import Foundation

struct HRSample: Codable {
  var rate: Double = 0.0
  var at: Date = Date()

  var percentOfMax: Double {
    return rate / User.maxHeartRate
  }

  var percentOfReserve: Double {
    return (rate - User.restingHeartRate) / User.reserveHR
  }

  var zone: TrainingZone {
    GarminTraining.zone(maxHR: User.maxHeartRate, heartRate: rate)
  }

  var description: String {
    zone.description
  }

  func toJson() -> String {
    guard let json = try? JSONEncoder().encode(self)
    else {
      return "{\"rate\": \(rate), \"at\": \(at)}"
    }
    return String(data: json, encoding: .utf8)!
  }
}
