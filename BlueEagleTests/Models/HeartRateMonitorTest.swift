//
//  HeartRateMonitorTest.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/19.
//

import XCTest

@testable import BlueEagle

class EventBusMonitor: EventBusObserver {
  var notifications: [Notification] = []

  let observing: [Selector: [NSNotification.Name]] = [
    #selector(notified(notification:)): [
      .BluetoothRequestScan,
      .BluetoothScanStarted,
      .BluetoothScanStopped,
      .BluetoothRequestConnection,
      .BluetoothRequestDisconnection,
      .HeartRateMonitorDiscovered,
      .HeartRateMonitorConnected,
      .HeartRateMonitorValueUpdated,
      .HeartRateMonitorDisconnected,
      .HeartRateMonitorDead,
    ]
  ]

  init() {
    EventBus.addObserver(self)
  }

  @objc func notified(notification: Notification) {
    notifications.append(notification)
  }

  func has(_ name: NSNotification.Name) -> Bool {
    notifications.contains(where: { $0.name == name })
  }

  func reset() {
    notifications.removeAll()
  }

  deinit {
    EventBus.removeObserver(self)
  }
}

@MainActor
final class HeartRateMonitorTest: XCTestCase {
  class TestDelegate: NSObject, HeartRateMonitorDelegate {

    class Call {
      var name: String
      var data: Double?

      init(_ name: String, data: Double) {
        self.name = name
        self.data = data
      }

      init(_ name: String) {
        self.name = name
      }
    }

    var calls: [Call] = []

    func disconnected() {
      calls.append(Call("disconnected"))
    }

    func connected() {
      calls.append(Call("connected"))
    }

    func sampleRecorded(_ value: Double) {
      calls.append(Call("sampleRecorded", data: value))
    }

    func has(_ name: String) -> Bool {
      calls.contains(where: { $0.name == name })
    }

    func has(_ name: String, _ data: Double) -> Bool {
      calls.contains(where: { $0.name == name && $0.data == data })
    }

    func reset() {
      calls.removeAll()
    }

  }
  let identifier = UUID()

  var userInfo: [AnyHashable: AnyHashable] = [:]
  let HEART_RATE_SAMPLE_1 = 90
  let HEART_RATE_SAMPLE_2 = 91
  let events: EventBusMonitor = .init()
  let delegate = TestDelegate()

  // MARK: Connecting
  func makeHeartRateMonitor() -> HeartRateMonitor {
    delegate.reset()
    let sut = HeartRateMonitor(identifier: identifier)
    sut.delegate = delegate

    return sut

  }
  func test_itRequestsConnection() throws {
    let sut = makeHeartRateMonitor()
    sut.connect()
    waitForNotification(.BluetoothRequestConnection)
    XCTAssertTrue(events.has(.BluetoothRequestConnection))
  }

  func test_itRequestsToggleToConnect() throws {
    let sut = makeHeartRateMonitor()
    sut.toggle()
    waitForNotification(.BluetoothRequestConnection)
    XCTAssertTrue(events.has(.BluetoothRequestConnection))
  }

  func test_itRequestsToggleToDisconnect() throws {
    let sut = makeHeartRateMonitor()
    EventBus.trigger(.HeartRateMonitorConnected, ["identifier": sut.identifier])
    waitForNotification(.HeartRateMonitorConnected)
    sut.toggle()
    waitForNotification(.BluetoothRequestDisconnection)
    XCTAssertTrue(events.has(.BluetoothRequestDisconnection))
  }

  func test_itRequestsDisconnection() throws {
    let sut = makeHeartRateMonitor()
    sut.disconnect()
    waitForNotification(.BluetoothRequestDisconnection)
    XCTAssertTrue(events.has(.BluetoothRequestDisconnection))
  }

  func test_connectedDelegate() {
    let sut = makeHeartRateMonitor()
    EventBus.trigger(.HeartRateMonitorConnected, ["identifier": sut.identifier])
    waitForNotification(.HeartRateMonitorConnected)
    XCTAssertTrue(delegate.has("connected"))
  }

  func test_disconnectedDelegate() {
    let sut = makeHeartRateMonitor()

    EventBus.trigger(.HeartRateMonitorConnected, ["identifier": sut.identifier])
    waitForNotification(.HeartRateMonitorConnected)

    EventBus.trigger(.HeartRateMonitorDisconnected, ["identifier": sut.identifier])
    waitForNotification(.HeartRateMonitorDisconnected)

    XCTAssertTrue(delegate.has("disconnected"))
  }

  func test_sampleRecordedDelegate() {
    let sut = makeHeartRateMonitor()

    EventBus.trigger(.HeartRateMonitorValueUpdated, ["identifier": sut.identifier, "sample": 120])
    waitForNotification(.HeartRateMonitorValueUpdated)
    XCTAssertTrue(delegate.has("sampleRecorded", 120))
  }

  func test_ignoresInvalidEvents() {
    let _ = makeHeartRateMonitor()

    EventBus.trigger(.HeartRateMonitorConnected, ["identifier": UUID()])
    waitForNotification(.HeartRateMonitorConnected)
    XCTAssertFalse(delegate.has("connected"))
  }

  func test_deadOnMaxIdenticalSamples() {
    let sut = makeHeartRateMonitor()

    EventBus.trigger(.HeartRateMonitorConnected, ["identifier": sut.identifier])
    waitForNotification(.HeartRateMonitorConnected)

    XCTAssertEqual(delegate.calls.last!.name, "connected")

    for _ in 0...sut.MAX_IDENTICAL_HEART_RATE {
      EventBus.trigger(
        .HeartRateMonitorValueUpdated, ["identifier": sut.identifier, "sample": 100])
    }
    // is still "connected" after maximum identical samples
    XCTAssertEqual(delegate.calls.last!.name, "connected")

    EventBus.trigger(.HeartRateMonitorValueUpdated, ["identifier": sut.identifier, "sample": 100])
    waitForNotification(.HeartRateMonitorValueUpdated)

    // is disconnected after maximum identical samples + 1
    XCTAssertEqual(delegate.calls.last!.name, "disconnected")

    EventBus.trigger(.HeartRateMonitorValueUpdated, ["identifier": sut.identifier, "sample": 99])
    waitForNotification(.HeartRateMonitorValueUpdated)

    // is re-connected after receiving a non-identical sample
    XCTAssertEqual(delegate.calls.last!.name, "connected")
  }
}
