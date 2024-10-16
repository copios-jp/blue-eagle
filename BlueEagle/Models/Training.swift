import Foundation
import SwiftUI

class Training: ObservableObject, EventBusObserver {
  private(set) var samples: [HRSample] = []
  private(set) var startedAt: Date?
  private(set) var endedAt: Date?
  private(set) var averageHR: Double = 0.0

  let uuid = UUID()
  let observing: [Selector: [NSNotification.Name]] = [
    #selector(heartRateMonitorValueUpdated(notification:)): [.HeartRateMonitorValueUpdated]
  ]
 
  init() {
    EventBus.addObserver(self)
  }

  deinit {
    EventBus.removeObserver(self)
  }

  var duration: DateComponents {
    let from = startedAt ?? Date()
    let to = endedAt ?? Date()

    return Calendar.current.dateComponents([.second, .minute, .hour], from: from, to: to)
  }

  func start() {
    guard endedAt == nil else { return }
    startedAt = Date()
  }

  func stop() {
    guard startedAt != nil else { return }
    endedAt = Date()
  }
    
  @objc private func heartRateMonitorValueUpdated(notification: Notification) {
    guard startedAt != nil && endedAt == nil else { return }
    addSample(notification.userInfo!["sample"] as! Double)
  }

  private func addSample(_ sample: Double, _ at: Date = Date()) {
    samples.append(HRSample(rate: sample, at: at))
    averageHR = averageHR + (sample - averageHR) / Double(samples.count)
  }
}
