//
//  HeartRateMonitorViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/17.
//

import Combine
import SwiftUI

class HeartRateMonitorViewModel: ObservableObject, Hashable, Equatable {
  struct HeartRateMonitorIcon {
    var systemName: String
    var foregroundColor: Color
  }

  static let LiveHeartRateMonitorIcon = HeartRateMonitorIcon(
    systemName: "heart.fill", foregroundColor: .primary)
  static let DeadHeartRateMonitorIcon = HeartRateMonitorIcon(
    systemName: "heart.slash", foregroundColor: .secondary)

  static func == (lhs: HeartRateMonitorViewModel, rhs: HeartRateMonitorViewModel) -> Bool {
    return lhs.identifier == rhs.identifier
  }

  private var eventBus: EventBus

  private var observing: [Selector: NSNotification.Name] = [
    #selector(heartRateMonitorConnected(notification:)): .HeartRateMonitorConnected,
    #selector(heartRateMonitorDead(notification:)): .HeartRateMonitorDead,
  ]

  private var heartRateMonitor: HeartRateMonitor

  @Published var name: String = "Unknown"
  @Published var icon: HeartRateMonitorIcon
  @Published var identifier: UUID = .init()

  init(_ heartRateMonitor: HeartRateMonitor, eventBus: EventBus = NotificationCenter.default) {
    self.heartRateMonitor = heartRateMonitor
    self.eventBus = eventBus
    name = heartRateMonitor.name
    identifier = heartRateMonitor.identifier
    icon = Self.DeadHeartRateMonitorIcon
    eventBus.registerObservers(self, observing)
  }

  private func isMine(_ notification: Notification) -> Bool {
    return notification.userInfo!["identifier"] as! UUID == identifier
  }

  @objc private func heartRateMonitorDead(notification: Notification) {
    if !isMine(notification) {
      return
    }
    icon = Self.DeadHeartRateMonitorIcon
  }

  @objc private func heartRateMonitorConnected(notification: Notification) {
    if !isMine(notification) {
      return
    }

    print("HeartRateMonitorViewModel CONNECTED")
    icon = Self.LiveHeartRateMonitorIcon
  }

  func toggle() {
    heartRateMonitor.toggle()
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
}
