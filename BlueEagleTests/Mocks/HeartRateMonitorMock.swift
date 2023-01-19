//
//  HeartRateMonitorDelegateMock.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/19.
//

import Foundation
@testable import BlueEagle

class HeartRateMonitorMock: HeartRateMonitorDelegate  {
  @Published var state: HeartRateMonitorState = .disconnected
  var statePublisher: Published<BlueEagle.HeartRateMonitorState>.Publisher { $state }
  
  var identifier: UUID = .init()
  var name: String = "Test"
  
  var wasConnected: Bool = false
  var wasDisconnected: Bool = false
  var wasToggled: Bool = false
  
  func connect() {
    wasConnected = true
    state = .connected
  }
  
  func disconnect() {
    wasDisconnected = true
    state = .disconnected
  }
  
  func toggle() {
    wasToggled = true
    state = state == .connected ? .disconnected : .connected
  }
}
