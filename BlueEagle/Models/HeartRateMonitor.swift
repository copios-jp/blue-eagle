//
//  HeartRateMonitor.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/15.
//

import Combine
import CoreBluetooth
import Foundation
import SwiftUI

enum HeartRateMonitorState: Int {
  case disconnected
  case disconnecting
  case connecting
  case connected
  // monitors will continue sending the last known value, or garbage when
  // connected but not actually measuring due to poor connectivity or
  // inaccurate placement/usage
  case dead
}

class HeartRateMonitor: ObservableObject {
  private let observing: [Selector: NSNotification.Name] = [
    #selector(heartRateMonitorValueUpdated(notification:)): .HeartRateMonitorValueUpdated,
    #selector(heartRateMonitorConnected(notification:)): .HeartRateMonitorConnected,
    #selector(heartRateMonitorDisconnected(notification:)): .HeartRateMonitorDisconnected,
  ]
  private let DEAD_STICK_COUNT: Int = 30

  private var eventBus: EventBus
  private var deadStickCountdown: Int

  @Published private(set) var state: HeartRateMonitorState = .dead
  @Published private(set) var value: Int = 0

  private(set) var name: String
  private(set) var identifier: UUID

  init(name: String = "Unknown", identifier: UUID = UUID(), eventBus: EventBus = NotificationCenter.default) {
    self.eventBus = eventBus
    self.name = name
    self.identifier = identifier
    deadStickCountdown = DEAD_STICK_COUNT
    eventBus.registerObservers(self, observing)
  }

  func connect() {
    state = .connecting
    eventBus.trigger(.BluetoothRequestConnection, ["identifier": identifier])
  }

  func disconnect() {
    state = .disconnecting
    eventBus.trigger(.BluetoothRequestDisconnection, ["identifier": identifier])
  }

  func toggle() {
    if state == .connected || state == .dead {
      disconnect()
    } else if state == .disconnected {
      connect()
    }
  }

  private func isMine(_ notification: Notification) -> Bool {
    let identifier: UUID = notification.userInfo!["identifier"] as! UUID
    return self.identifier == identifier
  }

  @objc private func heartRateMonitorConnected(notification: Notification) {
    if isMine(notification) { state = .connected }
  }

  @objc private func heartRateMonitorDisconnected(notification: Notification) {
    if isMine(notification) { state = .disconnected }
  }

  @objc private func heartRateMonitorValueUpdated(notification: Notification) {
    if isMine(notification) == false {
      return
    }

    let heartRate: Int = notification.userInfo!["heart_rate_measurement"] as! Int

    deadStickCountdown = heartRate != value ? DEAD_STICK_COUNT : deadStickCountdown - 1
    value = heartRate

    if deadStickCountdown <= 0 {
      state = .dead
    }
  }
}
