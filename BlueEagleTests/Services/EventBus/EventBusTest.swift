import XCTest
@testable import BlueEagle

final class EventBusTest: XCTestCase {
    var monitor: EventBusMonitor!
    
    override func setUpWithError() throws {
         monitor = .init()
    }

    override func tearDownWithError() throws {
        monitor = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddObserver() {}
    func testRemoveObserver() {}
   
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
