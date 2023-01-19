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
  override func setUpWithError() throws {
    sut = .init(identifier: identifier)
  }
  
  override func tearDownWithError() throws {
    sut = nil
  }
 
  func testConnectedEvent() throws {
    XCTAssertEqual(sut!.state, .dead)
    NotificationCenter.default.post(name: .HeartRateMonitorConnected, object:nil, userInfo: ["identifier": identifier])
    XCTAssertEqual(sut!.state, .connected)
  }
   
  func testDisonnectedEvent() throws {
    XCTAssertEqual(sut!.state, .dead)
    NotificationCenter.default.post(name: .HeartRateMonitorDisconnected, object:nil, userInfo: ["identifier": identifier])
    XCTAssertEqual(sut!.state, .disconnected)
  }
 
  
  func testConflictingIdentifierEvent() throws {
    XCTAssertEqual(sut!.state, .dead)
    NotificationCenter.default.post(name: .HeartRateMonitorConnected, object:nil, userInfo: ["identifier": UUID()])
    XCTAssertEqual(sut!.state, .dead)
  }
  func testValueUpdateEvent() throws {
    XCTAssertEqual(sut!.heartRate, 0)
    NotificationCenter.default.post(name: .HeartRateMonitorValueUpdated, object:nil, userInfo: ["identifier": identifier, "sample": 90])
    XCTAssertEqual(sut!.heartRate, 90)
    XCTAssertEqual(sut!.state, .connected)
  }

  func testDeadStick() throws {
    for _ in 0...30 {
     NotificationCenter.default.post(name: .HeartRateMonitorValueUpdated, object:nil, userInfo: ["identifier": identifier, "sample": 90])
    }
    
    XCTAssertEqual(sut!.state, .dead)
  }
  
  func testDeadStickRecovery() throws {
    NotificationCenter.default.post(name: .HeartRateMonitorConnected, object:nil, userInfo: ["identifier": identifier])
    
    for _ in 0...30 {
     NotificationCenter.default.post(name: .HeartRateMonitorValueUpdated, object:nil, userInfo: ["identifier": identifier, "sample": 90])
    }
    
    XCTAssertEqual(sut!.state, .dead)
    NotificationCenter.default.post(name: .HeartRateMonitorValueUpdated, object:nil, userInfo: ["identifier": identifier, "sample": 91])
    XCTAssertEqual(sut!.state, .connected)
  }
  
  func testConnect() throws {
    let eventBusMock: EventBusMock = .init()
    let sut: HeartRateMonitor = .init(identifier: identifier, eventBus: eventBusMock )
    sut.connect()
    XCTAssertEqual(eventBusMock.name, .BluetoothRequestConnection)
    XCTAssertEqual(eventBusMock.data?["identifier"] as! UUID, identifier)
  }
  
  func testDisconnect() throws {
    let eventBusMock: EventBusMock = .init()
    let sut: HeartRateMonitor = .init(identifier: identifier, eventBus: eventBusMock )
    sut.disconnect()
    XCTAssertEqual(eventBusMock.name, .BluetoothRequestDisconnection)
    XCTAssertEqual(eventBusMock.data?["identifier"] as! UUID, identifier)
  }
  
  func testToggleWhenConnected() throws {
     let eventBusMock: EventBusMock = .init()
    let sut: HeartRateMonitor = .init(identifier: identifier, eventBus: eventBusMock )
    sut.connect()
    sut.toggle()
    XCTAssertEqual(sut.state, .disconnecting)
    XCTAssertEqual(eventBusMock.name, .BluetoothRequestDisconnection)
  }
  
  func testToggleWhenDisconnected() throws {
    let eventBusMock: EventBusMock = .init()
    let sut: HeartRateMonitor = .init(identifier: identifier, eventBus: eventBusMock )
    sut.disconnect()
    sut.toggle()
    XCTAssertEqual(sut.state, .connecting)
    
    XCTAssertEqual(eventBusMock.name, .BluetoothRequestConnection)
  }
}
