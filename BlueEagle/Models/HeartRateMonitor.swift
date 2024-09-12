//
//  HeartRateMonitor.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/15.
//

import Foundation

class HeartRateMonitor {
  private enum HeartRateMonitorState: Int {
    case connected
    // monitors will continue sending the last known value, or garbage when
    // connected but not actually measuring due to poor connectivity or
    // inaccurate placement/usage
    // we treat disconnected and 'dead' as same state
    case dead
  }

  private let observing: [Selector: NSNotification.Name] = [
    #selector(heartRateMonitorValueUpdated(notification:)): .HeartRateMonitorValueUpdated,
    #selector(heartRateMonitorConnected(notification:)): .HeartRateMonitorConnected,
    #selector(heartRateMonitorDisconnected(notification:)): .HeartRateMonitorDisconnected,
  ]

  private let MAX_IDENTICAL_HEART_RATE: Int = 30
  private var identicalSampleCount: Int = 0

  private var state: HeartRateMonitorState = .dead {
    didSet {
      guard oldValue != state else { return }

      state == .dead ? delegate?.disconnected() : delegate?.connected()
    }
  }

  var lastSample: Double = 0
  let name: String
  let identifier: UUID

  weak var delegate: (any HeartRateMonitorDelegate)?

  init(name: String = "Unknown", identifier: UUID = UUID()) {
    self.name = name
    self.identifier = identifier

    EventBus.registerObservers(self, observing)
  }

  deinit {
    EventBus.removeObserver(self)
  }

  private func trigger(_ name: Notification.Name) {
    EventBus.trigger(name, ["identifier": identifier])
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
    }
  }

  @objc private func heartRateMonitorValueUpdated(notification: Notification) {
    validated(notification) { sample in
      identicalSampleCount = sample == lastSample ? identicalSampleCount + 1 : 0
      lastSample = sample

      state = identicalSampleCount >= MAX_IDENTICAL_HEART_RATE ? .dead : .connected
      delegate?.sampleRecorded(sample)
    }
  }

  func connect() {
    trigger(.BluetoothRequestConnection)
  }

  func disconnect() {
    trigger(.BluetoothRequestDisconnection)
  }

  func toggle() {
    state == .connected ? disconnect() : connect()
  }
}

protocol HeartRateMonitorDelegate: NSObjectProtocol {
  func sampleRecorded(_ value: Double)
  func connected()
  func disconnected()
}
