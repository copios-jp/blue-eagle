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

  let HEART_RATE_SAMPLE_1 = 90.0
  let HEART_RATE_SAMPLE_2 = 91.0
  var eventBusMonitor: EventBusMonitor!
  var delegate: TestDelegate!
  var sut: HeartRateMonitor!

  override func setUp() {
    eventBusMonitor = .init()
    delegate = .init()
    sut = HeartRateMonitor(identifier: UUID())
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
    PeripheralConnectedEvent(label: "test", identifier: sut.identifier).trigger()
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
    PeripheralConnectedEvent(label: "test", identifier: sut.identifier).trigger()
    waitForNotification(.HeartRateMonitorConnected)
    XCTAssertTrue(delegate.has("connected"))
  }

  func test_disconnectedDelegate() {
    PeripheralConnectedEvent(label: "test", identifier: sut.identifier).trigger()
    waitForNotification(.HeartRateMonitorConnected)

    PeripheralDisconnectedEvent(label: "test", identifier: sut.identifier).trigger()
    waitForNotification(.HeartRateMonitorDisconnected)

    XCTAssertTrue(delegate.has("disconnected"))
  }

  func test_sampleRecordedDelegate() {
    PeripheralValueUpdatedEvent(label: "test", identifier: sut.identifier).trigger(sample: HEART_RATE_SAMPLE_1)
    waitForNotification(.HeartRateMonitorValueUpdated)
    XCTAssertTrue(delegate.has("sampleRecorded", HEART_RATE_SAMPLE_1))
  }

  func test_ignoresInvalidEvents() {
    PeripheralConnectedEvent(label: "test", identifier: UUID()).trigger()
    waitForNotification(.HeartRateMonitorConnected)
    XCTAssertFalse(delegate.has("connected"))
  }

  func test_disconnectedOnMaxIdenticalSamples() {
    PeripheralConnectedEvent(label: "test", identifier: sut.identifier).trigger()
    waitForNotification(.HeartRateMonitorConnected)

    XCTAssertEqual(delegate.calls.last!.name, "connected")

    for _ in 0...sut.MAX_IDENTICAL_HEART_RATE {
      PeripheralValueUpdatedEvent(label: "test", identifier: sut.identifier).trigger(
        sample: HEART_RATE_SAMPLE_1)
    }
    // is still "connected" after maximum identical samples
    XCTAssertEqual(delegate.calls.last!.name, "connected")

    PeripheralValueUpdatedEvent(label: "test", identifier: sut.identifier).trigger(
      sample: HEART_RATE_SAMPLE_1)
    waitForNotification(.HeartRateMonitorValueUpdated)

    // is disconnected after maximum identical samples + 1
    XCTAssertEqual(delegate.calls.last!.name, "disconnected")

    PeripheralValueUpdatedEvent(label: "test", identifier: sut.identifier).trigger(
      sample: HEART_RATE_SAMPLE_2)
    waitForNotification(.HeartRateMonitorValueUpdated)

    // is re-connected after receiving a non-identical sample
    XCTAssertEqual(delegate.calls.last!.name, "connected")
  }
}
