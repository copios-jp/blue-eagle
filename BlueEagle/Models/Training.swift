//
//  Training.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/28.
//
import Foundation
import SwiftUI

// TODO collect heart rate samples during the training for generating reports.
class Training: ObservableObject {

  private let observing: [Selector: NSNotification.Name] = [
    #selector(heartRateMonitorValueUpdated(notification:)): .HeartRateMonitorValueUpdated
  ]

  init() {
    EventBus.registerObservers(self, observing)
  }

  var samples: [HRSample] = []

  private(set) var startedAt: Date?
  private(set) var endedAt: Date?

  let uuid = UUID()

  var duration: DateComponents {
    let from = startedAt ?? Date()
    let to = endedAt ?? Date()

    return Calendar.current.dateComponents([.second, .minute, .hour], from: from, to: to)
  }

  private(set) var averageHR: Double = 0.0

  @objc private func heartRateMonitorValueUpdated(notification: Notification) {
    if startedAt == nil {
      startedAt = Date()
    }
    addSample(notification.userInfo!["sample"] as! Double)
  }
  func addSample(_ sample: Double, _ at: Date = Date()) {
    samples.append(HRSample(rate: sample, at: at))

    averageHR = averageHR + (sample - averageHR) / Double(samples.count)
  }
}
