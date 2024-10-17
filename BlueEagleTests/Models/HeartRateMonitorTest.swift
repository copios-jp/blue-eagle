//
//  HeartRateMonitorTest.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/19.
//

import XCTest

@testable import BlueEagle

@MainActor
final class HeartRateMonitorTest: XCTestCase {
  class TestDelegate: DelegateSpy, HeartRateMonitorDelegate {
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
  }

  let identifier = UUID()
  var userInfo: [AnyHashable: AnyHashable] = [:]
  let HEART_RATE_SAMPLE_1 = 90
  let HEART_RATE_SAMPLE_2 = 91
  var eventBusMonitor: EventBusMonitor!// = .init()
  var delegate: TestDelegate!

  var sut: HeartRateMonitor!
  override func setUp() {
    //super.setUp()
    eventBusMonitor = .init()
    delegate = .init()
    sut = HeartRateMonitor(identifier: identifier)
    sut.delegate = delegate
  }

  override func tearDown() {
    sut = nil
    delegate = nil
    eventBusMonitor = nil
  }

  func test_itRequestsConnection() throws {
    sut.connect()
    waitForNotification(.BluetoothRequestConnection)
    XCTAssertTrue(eventBusMonitor.has(.BluetoothRequestConnection))
  }

  func test_itRequestsToggleToConnect() throws {
    sut.toggle()
    waitForNotification(.BluetoothRequestConnection)
    XCTAssertTrue(eventBusMonitor.has(.BluetoothRequestConnection))
  }

  func test_itRequestsToggleToDisconnect() throws {
    EventBus.trigger(.HeartRateMonitorConnected, ["identifier": sut.identifier])
    waitForNotification(.HeartRateMonitorConnected)
    sut.toggle()
    waitForNotification(.BluetoothRequestDisconnection)
      XCTAssertTrue(eventBusMonitor.has(.BluetoothRequestDisconnection))
  }

  func test_itRequestsDisconnection() throws {
    sut.disconnect()
    waitForNotification(.BluetoothRequestDisconnection)
    XCTAssertTrue(eventBusMonitor.has(.BluetoothRequestDisconnection))
  }

  func test_connectedDelegate() {
    EventBus.trigger(.HeartRateMonitorConnected, ["identifier": sut.identifier])
    waitForNotification(.HeartRateMonitorConnected)
    XCTAssertTrue(delegate.has("connected"))
  }

  func test_disconnectedDelegate() {
    EventBus.trigger(.HeartRateMonitorConnected, ["identifier": sut.identifier])
    waitForNotification(.HeartRateMonitorConnected)

    EventBus.trigger(.HeartRateMonitorDisconnected, ["identifier": sut.identifier])
    waitForNotification(.HeartRateMonitorDisconnected)

    XCTAssertTrue(delegate.has("disconnected"))
  }

  func test_sampleRecordedDelegate() {
    EventBus.trigger(.HeartRateMonitorValueUpdated, ["identifier": sut.identifier, "sample": 120])
    waitForNotification(.HeartRateMonitorValueUpdated)
    XCTAssertTrue(delegate.has("sampleRecorded", 120))
  }

  func test_ignoresInvalidEvents() {
    EventBus.trigger(.HeartRateMonitorConnected, ["identifier": UUID()])
    waitForNotification(.HeartRateMonitorConnected)
    XCTAssertFalse(delegate.has("connected"))
  }

  func test_deadOnMaxIdenticalSamples() {
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
