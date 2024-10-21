import XCTest

@testable import BlueEagle

func WithUser(
  birthdate: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date())!,
  restingHeartRate: Int = 50
) {
  User.current.birthdate = birthdate
  User.current.restingHeartRate = restingHeartRate
}

class DelegateSpy: NSObject {
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
}

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

  deinit {
    EventBus.removeObserver(self)
  }
}

@MainActor
extension XCTestCase {
  func waitForNotification(_ notification: Notification.Name) {
    let expectation = XCTNSNotificationExpectation(name: notification)
    wait(for: [expectation], timeout: 1)
  }
}
