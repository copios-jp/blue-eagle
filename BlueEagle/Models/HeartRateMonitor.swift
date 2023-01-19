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

protocol HeartRateMonitorDelegate {
  
  var statePublisher: Published<HeartRateMonitorState>.Publisher { get }
  var identifier: UUID { get }
  var name: String { get }
  
  func connect()
  func disconnect()
  func toggle()
}

class HeartRateMonitor: ObservableObject, HeartRateMonitorDelegate {
  private let observing: [Selector: NSNotification.Name] = [
    #selector(heartRateMonitorValueUpdated(notification:)): .HeartRateMonitorValueUpdated,
    #selector(heartRateMonitorConnected(notification:)): .HeartRateMonitorConnected,
    #selector(heartRateMonitorDisconnected(notification:)): .HeartRateMonitorDisconnected,
  ]
  
  static let MAX_IDENTICAL_HEART_RATE: Int = 30

  private var eventBus: EventBus
  private var deadStickCountdown: Int

  @Published private(set) var state: HeartRateMonitorState = .dead
  @Published private(set) var heartRate: Int = 0
  var statePublisher: Published<HeartRateMonitorState>.Publisher { $state }
  
  private(set) var name: String
  private(set) var identifier: UUID

  init(name: String = "Unknown", identifier: UUID = UUID(), eventBus: EventBus = NotificationCenter.default) {
    self.eventBus = eventBus
    self.name = name
    self.identifier = identifier
    deadStickCountdown = HeartRateMonitor.MAX_IDENTICAL_HEART_RATE
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
    if state != .disconnected && state != .disconnecting {
      disconnect()
    } else if state != .connected && state != .connecting {
      connect()
    }
  }

  private func isMine(_ notification: Notification) -> Bool {
    let identifier: UUID = notification.userInfo!["identifier"] as! UUID
    return self.identifier == identifier
  }

  @objc private func heartRateMonitorConnected(notification: Notification) {
    if isMine(notification) {
      state = .connected
      
    }
  }

  @objc private func heartRateMonitorDisconnected(notification: Notification) {
    if isMine(notification) {
      state = .disconnected
    }
  }

  @objc private func heartRateMonitorValueUpdated(notification: Notification) {
    if isMine(notification) == false {
      return
    }

    let newValue: Int = notification.userInfo!["sample"] as! Int

    deadStickCountdown = newValue != heartRate ? HeartRateMonitor.MAX_IDENTICAL_HEART_RATE : max(deadStickCountdown - 1, 0)
    heartRate = newValue

    if deadStickCountdown == 0 && state != .dead {
      state = .dead
    } else if state != .connected {
      state = .connected
    }
  }
}
