//
//  HeartRateMonitor.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/15.
//

// import Combine
// import CoreBluetooth
import Foundation

enum HeartRateMonitorState: Int {
  case connected
  // monitors will continue sending the last known value, or garbage when
  // connected but not actually measuring due to poor connectivity or
  // inaccurate placement/usage
  // we treat disconnected and 'dead' as same state
  case dead
}

class HeartRateMonitor {

  private let observing: [Selector: NSNotification.Name] = [
    #selector(heartRateMonitorValueUpdated(notification:)): .HeartRateMonitorValueUpdated,
    #selector(heartRateMonitorConnected(notification:)): .HeartRateMonitorConnected,
    #selector(heartRateMonitorDisconnected(notification:)): .HeartRateMonitorDisconnected,
  ]

  static let MAX_IDENTICAL_HEART_RATE: Int = 30

  private var eventBus: EventBus
  private var remainingAllowedIdenticalSamples: Int
  private var hasTooManyIdenticalSamples: Bool { remainingAllowedIdenticalSamples == 0 }

  private(set) var state: HeartRateMonitorState = .dead
  private(set) var heartRate: Double = 0

  private(set) var name: String
  private(set) var identifier: UUID

  init(
    name: String = "Unknown", identifier: UUID = UUID(),
    eventBus: EventBus = NotificationCenter.default
  ) {
    self.eventBus = eventBus
    self.name = name
    self.identifier = identifier
    remainingAllowedIdenticalSamples = Self.MAX_IDENTICAL_HEART_RATE

    eventBus.registerObservers(self, observing)
  }

  deinit {
    eventBus.removeObserver(self)
  }

  private func updateRemainingAllowedIdenticalSamples(_ newValue: Double) {
    if newValue != heartRate {
      remainingAllowedIdenticalSamples = Self.MAX_IDENTICAL_HEART_RATE
      return
    }

    remainingAllowedIdenticalSamples = max(remainingAllowedIdenticalSamples - 1, 0)

    let hasDied = hasTooManyIdenticalSamples && state == .connected
    let hasRevived = !hasTooManyIdenticalSamples && state == .dead

    if hasDied {
      state = .dead
      trigger(.HeartRateMonitorDead)
    }

    if hasRevived {
      state = .connected
      trigger(.HeartRateMonitorConnected)
    }
  }

  private func trigger(_ name: Notification.Name) {
    eventBus.trigger(name, ["identifier": identifier])
  }

  private func isMine(_ notification: Notification) -> Bool {
    return notification.userInfo!["identifier"] as! UUID == identifier
  }

  private func validated(_ notification: Notification, _ proc: (_ sample: Double) -> Void) {
    if isMine(notification) {
      let sample: Double = notification.userInfo!["sample"] as! Double
      proc(sample)
    }
  }

  private func validated(_ notification: Notification, _ proc: () -> Void) {
    if isMine(notification) {
      proc()
    }
  }

  @objc private func heartRateMonitorConnected(notification: Notification) {
    validated(notification) {
      state = .connected
    }
  }

  @objc private func heartRateMonitorDisconnected(notification: Notification) {
    validated(notification) {
      state = .dead
      trigger(.HeartRateMonitorDead)
    }
  }

  @objc private func heartRateMonitorValueUpdated(notification: Notification) {
    validated(notification) { sample in
      updateRemainingAllowedIdenticalSamples(sample)
      heartRate = sample
    }
  }

  func connect() {
    remainingAllowedIdenticalSamples = Self.MAX_IDENTICAL_HEART_RATE
    trigger(.BluetoothRequestConnection)
  }

  func disconnect() {
    trigger(.BluetoothRequestDisconnection)
  }

  func toggle() {
    state == .connected ? disconnect() : connect()
  }
}
