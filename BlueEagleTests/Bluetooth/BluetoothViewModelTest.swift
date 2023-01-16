//
//  BluetoothViewModelTest.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/15.
//
@testable import BlueEagle

import CoreBluetooth
import XCTest

final class BluetoothViewModelTest: XCTestCase {
    class EventBusMock: EventBus {
        var observing: [String] = []
        var notification: String? = nil
        var payload: [AnyHashable: Any]? = nil
        
        func trigger(_ name: NSNotification.Name, _ data: [AnyHashable: Any]) {
            self.notification = name.rawValue
            self.payload = data
        }
        func trigger(_ name: NSNotification.Name) {
            self.notification = name.rawValue
            self.payload = nil
        }
        
        func registerObservers(_ observing: [Selector: NSNotification.Name]) {
            self.observing = []
            observing.forEach { key, value in
                self.observing.append(value.rawValue)
            }
        }
         
        func clear() {
            self.observing = []
            self.notification = nil
            self.payload = nil
        }
    }
    
    var eventBusMock = EventBusMock()
    var subject: BluetoothViewModel!
    
    override func setUpWithError() throws {
      subject = BluetoothViewModel(eventBusMock)
    }

    override func tearDownWithError() throws {
        subject = nil
        eventBusMock.clear()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_scan() {
        subject.scan()
        XCTAssertEqual(eventBusMock.notification, "bluetooth_request_scan")
    }
    
    func test_connect() {
      subject.scan()
      XCTAssertEqual(eventBusMock.notification, "bluetooth_request_scan")
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
