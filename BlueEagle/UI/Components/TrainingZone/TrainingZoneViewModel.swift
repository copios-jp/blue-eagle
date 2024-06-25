//
//  TrainingZoneViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/06/24.
//

import Foundation
import SwiftUI

extension TrainingZoneView {
  class ViewModel: ObservableObject {
    private var eventBus: EventBus

    private let observing: [Selector: NSNotification.Name] = [
      #selector(heartRateMonitorValueUpdated(notification:)): .HeartRateMonitorValueUpdated
    ]

    @Published var percentOfMax: Double = 0.0
    var percentOfMaxLabel = "0%"
    var color: Color = .gray
    var description: String = "unknown"
    var gradient = TrainingZoneGradientStyle.gradient

    init(_ eventBus: EventBus = NotificationCenter.default) {
      self.eventBus = eventBus

      eventBus.registerObservers(self, observing)

    }

    @objc private func heartRateMonitorValueUpdated(notification: Notification) {
      let sample = HRSample(rate: notification.userInfo!["sample"] as! Double)
      self.percentOfMax = sample.percentOfMax
      self.percentOfMaxLabel = String(format: "%.0f%", sample.percentOfMax * 100.0)
      self.color = TrainingZoneGradientStyle.color(position: sample.zone.position)
      self.description = sample.description
    }
  }
}
