//
//  HeartRateMonitorTest.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/19.
//

import XCTest

@testable import BlueEagle

final class HeartRateMonitorTest: XCTestCase {
  var sut: HeartRateMonitor?
  let identifier = UUID()
  let eventBus: EventBusMock = .init()

  var userInfo: [AnyHashable: AnyHashable] = [:]
  let HEART_RATE_SAMPLE_1 = 90
  let HEART_RATE_SAMPLE_2 = 91

  override func setUpWithError() throws {
    userInfo = ["identifier": identifier]
    sut = .init(identifier: identifier)
  }

  override func tearDownWithError() throws {
    // EventBus.reset()
    sut = nil
  }

  // MARK: Connecting

  func test_itRequestsConnection() throws {
    sut!.connect()

    XCTAssertTrue(eventBus.hasCall(.BluetoothRequestConnection, userInfo))
  }

  func test_itTogglesToConnecting() throws {
    eventBus.trigger(.HeartRateMonitorDisconnected, userInfo)
    sut!.toggle()

    XCTAssertTrue(eventBus.hasCall(.BluetoothRequestConnection, userInfo))
  }

  func test_itTransitionsToConnectedState() throws {
    eventBus.trigger(.HeartRateMonitorConnected, userInfo)
    XCTAssertEqual(sut!.state, .connected)
  }

  // MARK: Disonnecting

  func test_itRequestsDisconnecting() throws {
    sut!.disconnect()

    XCTAssertTrue(eventBus.hasCall(.BluetoothRequestDisconnection, userInfo))
  }

  func test_itTogglesToDisconnecting() throws {
    eventBus.trigger(.HeartRateMonitorConnected, userInfo)
    sut!.toggle()

    XCTAssertTrue(eventBus.hasCall(.BluetoothRequestDisconnection, userInfo))
  }

  func test_itTransitionsToDisconnectedState() throws {
    eventBus.trigger(.HeartRateMonitorDisconnected, userInfo)
    XCTAssertTrue(eventBus.hasCall(.HeartRateMonitorDead, userInfo))
  }

  // MARK: Sampling

  func test_itCapturesHeartRateSamples() throws {
    XCTAssertEqual(sut!.lastSample, 0)
    let payload = userInfo.merging(["sample": 90]) { (_, new) in new }
    eventBus.trigger(.HeartRateMonitorValueUpdated, payload)
    XCTAssertEqual(sut!.lastSample, 90)
  }

    /*
  func test_itTransitionsToDeadStateAfterTooManyIdenticalSamples() throws {
    eventBus.trigger(.BluetoothPeripheralConnected, userInfo)

    for _ in 0...HeartRateMonitor.MAX_IDENTICAL_HEART_RATE {

      let payload = userInfo.merging(["sample": HEART_RATE_SAMPLE_1]) { (_, new) in new }
      eventBus.trigger(.HeartRateMonitorValueUpdated, payload)
    }

    XCTAssertTrue(eventBus.hasCall(.HeartRateMonitorDead, ["identifier": identifier]))
  }

  func test_itRecoversFromDeadStateWithDifferentSample() throws {
    eventBus.trigger(.BluetoothPeripheralConnected, userInfo)

    let identicalPayload = userInfo.merging(["sample": HEART_RATE_SAMPLE_1]) { (_, new) in new }
    let uniquePayload = userInfo.merging(["sample": HEART_RATE_SAMPLE_2]) { (_, new) in new }

    for _ in 0...HeartRateMonitor.MAX_IDENTICAL_HEART_RATE {
      eventBus.trigger(.HeartRateMonitorValueUpdated, identicalPayload)
    }
    eventBus.trigger(.HeartRateMonitorValueUpdated, uniquePayload)

    XCTAssertTrue(eventBus.hasCall(.HeartRateMonitorConnected, userInfo))
  }
*/
  // MARK: Identification

  func test_itIgnoresMessagesWithConflictingIdentifier() throws {
    eventBus.trigger(.BluetoothPeripheralConnected, ["identifier": UUID()])
    XCTAssertFalse(eventBus.hasCall(.HeartRateMonitorConnected, userInfo))
  }
}
