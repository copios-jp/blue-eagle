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
    case dead
  }

  let observing: [Selector: [NSNotification.Name]] = [
    #selector(heartRateMonitorValueUpdated(notification:)): [.HeartRateMonitorValueUpdated],
    #selector(heartRateMonitorConnected(notification:)): [.HeartRateMonitorConnected],

    #selector(heartRateMonitorDisconnected(notification:)): [.HeartRateMonitorDisconnected],
  ]

  private(set) var identicalSampleCount: Int = 0
  private(set) var lastSample: Double = 0
  private(set) var state: HeartRateMonitorState = .dead {
    didSet {
      guard oldValue != state else { return }
      if state == .connected {
        identicalSampleCount = 0
      }
      switch state {
      case .dead:
        delegate?.disconnected()
      case .connected:
        delegate?.connected()
      }
    }
  }

  let MAX_IDENTICAL_HEART_RATE: Int = 30
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

  private func trigger(_ name: Notification.Name) {
    EventBus.trigger(name, ["identifier": identifier])
  }

  private func isMine(_ notification: Notification) -> Bool {
    return notification.userInfo!["identifier"] as! UUID == identifier
  }

  private func validated(_ notification: Notification, _ proc: (_ sample: Double) -> Void) {
    if isMine(notification) {
      let sample: Double = notification.userInfo!["sample"] as! Double
      proc(sample)
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
      state = .dead
    }
  }

  @objc private func heartRateMonitorValueUpdated(notification: Notification) {
    validated(notification) { sample in
      identicalSampleCount = sample == lastSample ? identicalSampleCount + 1 : 0
      lastSample = sample

      delegate?.sampleRecorded(sample)

      state = identicalSampleCount > MAX_IDENTICAL_HEART_RATE ? .dead : .connected
    }
  }

  func connect() {
    trigger(.BluetoothRequestConnection)
  }

  func disconnect() {
    trigger(.BluetoothRequestDisconnection)
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
