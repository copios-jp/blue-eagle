import Foundation
import CoreBluetooth

protocol EventBusEvent {
  var name: NSNotification.Name { get }
  func trigger()
}

extension EventBusEvent {
  func trigger() {
    EventBus.trigger(self)
  }
}

// MARK: - Bluetooth service events

struct BluetoothServiceDidUpdateStateEvent: EventBusEvent {
  let name: NSNotification.Name = .BluetoothServiceDidUpdateState
  var state: CBManagerState
}

struct BluetoothRequestScanEvent: EventBusEvent {
  let name: NSNotification.Name = .BluetoothRequestScan
  static func trigger() {
    BluetoothRequestScanEvent().trigger()
  }
}

struct BluetoothScanStartedEvent: EventBusEvent {
  let name: NSNotification.Name = .BluetoothScanStarted
  static func trigger() {
    BluetoothScanStartedEvent().trigger()
  }

}

struct BluetoothScanStoppedEvent: EventBusEvent {
  let name: NSNotification.Name = .BluetoothScanStopped
  static func trigger() {
    BluetoothScanStoppedEvent().trigger()
  }
}

struct BluetoothRequestConnectionEvent: EventBusEvent {
  let name: NSNotification.Name = .BluetoothRequestConnection
  var identifier: UUID
    
  static func trigger(identifier: UUID) {
     BluetoothRequestConnectionEvent(identifier: identifier).trigger()
  }
}

struct BluetoothRequestDisconnectionEvent: EventBusEvent {
  let name: NSNotification.Name = .BluetoothRequestDisconnection
  var identifier: UUID
    
  static func trigger(identifier: UUID) {
    BluetoothRequestDisconnectionEvent(identifier: identifier).trigger()
  }
}

// MARK: - Peripheral Events

class PeripheralEvent: EventBusEvent {
  var label: String
  var identifier: UUID
  var name: NSNotification.Name
    
  static func from(_ peripheral: CBPeripheral) -> Self {
    return Self.init(label: peripheral.name ?? "Unknown", identifier: peripheral.identifier)
  }

  required init(label: String, identifier: UUID) {
    self.label = label
    self.identifier = identifier
    self.name = NSNotification.Name("NOOP")
  }
}

class PeripheralDiscoveredEvent: PeripheralEvent {
  required init(label: String, identifier: UUID) {
    super.init(label: label, identifier: identifier)
    self.name = NSNotification.Name.HeartRateMonitorDiscovered
  }
}

class PeripheralConnectedEvent: PeripheralEvent {
  required init(label: String, identifier: UUID) {
    super.init(label: label, identifier: identifier)
    self.name = NSNotification.Name.HeartRateMonitorConnected
  }
}

class PeripheralDisconnectedEvent: PeripheralEvent {
  required init(label: String, identifier: UUID) {
    super.init(label: label, identifier: identifier)
    self.name = NSNotification.Name.HeartRateMonitorDisconnected
  }
}

class PeripheralValueUpdatedEvent: PeripheralEvent {
  var sample: Double = 0
    
  init(label: String, identifier: UUID, sample: Double) {
      self.sample = sample
      super.init(label: label, identifier: identifier)
  }
    
  required init(label: String, identifier: UUID) {
    super.init(label: label, identifier: identifier)
    self.name = NSNotification.Name.HeartRateMonitorValueUpdated
  }

  func trigger(sample: Double) {
    self.sample = sample
    EventBus.trigger(self)
  }
}
