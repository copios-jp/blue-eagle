import Foundation

/// A model object that interacts with the ``BluetoothService`` via the EventBus to manage
/// connectivity while providing a delegate to monitor for changes
///
/// When a heart rate monitor is discovered an instance of this model is how we monitor the connection
/// and changes to the heart rate for consumption by view models.
///
/// In addition to observing changes in the connection status as notified from the bluetooth service, this model
/// also keeps track of consecutive, identical heart rate samples and notifies delegates that the monitor is disconnected
/// when the heart rate was identical for the last 30 samples.
class HeartRateMonitor: EventBusObserver {
  enum HeartRateMonitorState: Int {
    case connected
    case disconnected
  }

  let observing: [Selector: [NSNotification.Name]] = [
    #selector(heartRateMonitorConnected(notification:)): [.HeartRateMonitorConnected],
    #selector(heartRateMonitorDisconnected(notification:)): [.HeartRateMonitorDisconnected],
  ]

  private(set) var state: HeartRateMonitorState = .disconnected {
    didSet {
      guard oldValue != state else { return }
      state == .disconnected ? delegate?.disconnected() : delegate?.connected()
    }
  }

  let name: String
  let identifier: UUID

  weak var delegate: (any HeartRateMonitorDelegate)?

  init(name: String = "Unknown", identifier: UUID = UUID()) {
    self.name = name
    self.identifier = identifier

    EventBus.addObserver(self)
  }

  deinit {
    EventBus.removeObserver(self)
  }
    
  private func isMine(_ notification: Notification) -> Bool {
    let event = notification.object as! PeripheralEvent
    return event.identifier == identifier
  }

  private func validated(_ notification: Notification, _ proc: (_ sample: Double) -> Void) {
    if isMine(notification) {
        let event = notification.object as! PeripheralValueUpdatedEvent
        proc(event.sample)
    }
  }

  private func validated(_ notification: Notification, _ proc: () -> Void) {
    if isMine(notification) {
      proc()
    }
  }
    
  @objc private func heartRateMonitorConnected(notification: Notification) {
    validated(notification) {
      state = .connected
    }
  }
    
  @objc private func heartRateMonitorDisconnected(notification: Notification) {
    validated(notification) {
      state = .disconnected
    }
  }

  func connect() {
      BluetoothRequestConnectionEvent.trigger(identifier: identifier)
  }

  func disconnect() {
      BluetoothRequestDisconnectionEvent.trigger(identifier: identifier)
  }

  func toggle() {
    state == .connected ? disconnect() : connect()
  }
}

protocol HeartRateMonitorDelegate: NSObjectProtocol {
  func sampleRecorded(_ value: Double)
  func connected()
  func disconnected()
}
