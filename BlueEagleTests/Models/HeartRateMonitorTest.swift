//
//  HeartRateMonitorTest.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/19.
//

@testable import BlueEagle
import XCTest

final class HeartRateMonitorTest: XCTestCase {
  var sut: HeartRateMonitor?
  let identifier = UUID()
  let eventBus: EventBusMock = .init()
  
  let HEART_RATE_SAMPLE_1 = 90
  let HEART_RATE_SAMPLE_2 = 91
  
  override func setUpWithError() throws {
    sut = .init(identifier: identifier, eventBus: eventBus)
  }
  
  override func tearDownWithError() throws {
    eventBus.reset()
    sut = nil
  }
 
  // MARK: Connecting
  
  func test_itTransitionsToConnectingState() throws {
    sut!.connect()
    
    XCTAssertEqual(sut!.state, .connecting)
    XCTAssertTrue(eventBus.hasCall(.BluetoothRequestConnection, ["identifier": identifier]))
  }
  
  func test_itTogglesToConnecting() throws {
    sut!.disconnect()
    sut!.toggle()
    
    XCTAssertEqual(sut!.state, .connecting)
    XCTAssertTrue(eventBus.hasCall(.BluetoothRequestConnection, ["identifier": identifier]))
  }
  
  func test_itTransitionsToConnectedState() throws {
    XCTAssertEqual(sut!.state, .dead)
    
    eventBus.trigger(.HeartRateMonitorConnected, ["identifier": identifier])
    
    XCTAssertEqual(sut!.state, .connected)
  }
  
  // MARK: Disonnecting
  
  func test_itTransitionsToDisconnectingState() throws {
    sut!.disconnect()
    
    XCTAssertEqual(sut!.state, .disconnecting)
    XCTAssertTrue(eventBus.hasCall(.BluetoothRequestDisconnection, ["identifier": identifier]))
  }
   
  func test_itTogglesToDisconnecting() throws {
    sut!.connect()
    sut!.toggle()
    
    XCTAssertEqual(sut!.state, .disconnecting)
    XCTAssertTrue(eventBus.hasCall(.BluetoothRequestDisconnection, ["identifier": identifier]))
  }

  func test_itTransitionsToDisconnectedState() throws {
    XCTAssertEqual(sut!.state, .dead)
    
    eventBus.trigger(.HeartRateMonitorDisconnected, ["identifier": identifier])
    
    XCTAssertEqual(sut!.state, .disconnected)
  }
  
  // MARK: Sampling
  
  func test_itCapturesHeartRateSamples() throws {
    XCTAssertEqual(sut!.heartRate, 0)
    XCTAssertEqual(sut!.state, .dead)
    
    eventBus.trigger(.HeartRateMonitorValueUpdated, ["identifier": identifier, "sample": 90])
    
    XCTAssertEqual(sut!.heartRate, 90)
    XCTAssertEqual(sut!.state, .connected)
  }
  
  func test_itTransitionsToDeadStateAfterTooManyIdenticalSamples() throws {
    for _ in 0...HeartRateMonitor.MAX_IDENTICAL_HEART_RATE {
      eventBus.trigger(.HeartRateMonitorValueUpdated, ["identifier": identifier, "sample": HEART_RATE_SAMPLE_1])
    }
    
    XCTAssertEqual(sut!.state, .dead)
  }
  
  func test_itRecoversFromDeadStateWithDifferentSample() throws {
    eventBus.trigger(.HeartRateMonitorConnected, ["identifier": identifier])
    
    for _ in 0...HeartRateMonitor.MAX_IDENTICAL_HEART_RATE {
      eventBus.trigger(.HeartRateMonitorValueUpdated, ["identifier": identifier, "sample": HEART_RATE_SAMPLE_1])
    }
    
    XCTAssertEqual(sut!.state, .dead)
    
    eventBus.trigger(.HeartRateMonitorValueUpdated, ["identifier": identifier, "sample": HEART_RATE_SAMPLE_2])
    
    XCTAssertEqual(sut!.state, .connected)
  }
 
  // MARK: Identification
  
  func test_itIgnoresMessagesWithConflictingIdentifier() throws {
    XCTAssertEqual(sut!.state, .dead)
    
    eventBus.trigger(.HeartRateMonitorConnected, ["identifier": UUID()])
    
    XCTAssertEqual(sut!.state, .dead)
  }
 }
