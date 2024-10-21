//
//  BluetoothService.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/21.
//
import CoreBluetooth
import Foundation
import Combine

/// BluetoothService
///
/// This service abstracts interaction with the device bluetooth manager and peripherals limitied specifically to heart rate monitors.
/// All interactions with the service must come via ``EventBusNotificationCenter`` notifications.
///
/// # Endpoints
/// - BluetoothRequestScan
/// - BluetoothRequestConnection
/// - BlueRequestDisconnection
///
///   Trigger these events via thier structs
///    ```swift
///
///    BluetoothRequestConnectionEvent(identifier: identifier).trigger()
///
///    ```
///
/// # Events
///
/// - BluetoothScanStarted
/// - BluetoothScanStopped
/// - HeartRateMonitorDiscovered [name: String, identifier: UUID]
/// - HeartRateMonitorConnected [name: String, identifier: UUID]
/// - HeartRateMonitorDisconnected [name: String, identifier: UUID]
/// - HeartRateMonitorValueUpdated [name: String, identifier: UUID, sample: Double]
final class BluetoothService: NSObject, EventBusObserver  {
  private struct Gatt {
    // @see Assigned_Numbers.pdf in repo docs
    static let HeartRateMonitor = CBUUID(string: "0x180D")
    static let HeartRateMeasurment = CBUUID(string: "0x2A37")
  }
    
  private let manager: CBCentralManager = CBCentralManager()
  private var ref: CBPeripheral?

  let observing: [Selector: [NSNotification.Name]] = [
    #selector(bluetoothRequestScan(notification:)): [.BluetoothRequestScan],
    #selector(bluetoothRequestConnection(notification:)): [.BluetoothRequestConnection],
    #selector(bluetoothRequestDisconnection(notification:)): [.BluetoothRequestDisconnection],
  ]

  override init() {
    super.init()

    EventBus.addObserver(self)
    manager.delegate = self
  }
 
  deinit {
    EventBus.removeObserver(self)
  }
    
  @objc private func bluetoothRequestScan(notification _: Notification) {
    scan()
  }

  @objc private func bluetoothRequestConnection(notification: Notification) {
      let event = notification.object as! BluetoothRequestConnectionEvent
      connect(event.identifier)
  }

  @objc private func bluetoothRequestDisconnection(notification: Notification) {
      let event = notification.object as! BluetoothRequestDisconnectionEvent
      disconnect(event.identifier)
  }

  private func scan(_ timeout: Double = 5.0) {
    guard manager.state == CBManagerState.poweredOn && manager.isScanning == false else {
      return
    }
      
    disconnectAll()
      
    manager.scanForPeripherals(withServices: [Gatt.HeartRateMonitor], options: nil)
    BluetoothScanStartedEvent.trigger()


    Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) {
      [weak self] _ in
      self?.stopScan()
    }
  }
    
  private func connect(_ uuid: UUID, _ timeout: Double = 5.0) {
    guard let peripheral = getPeripheral(uuid) else {
      return
        
    }

    ref = peripheral
    peripheral.delegate = self

    manager.connect(peripheral, options: nil)

    Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) {
      [weak self] _ in

      guard let peripheral = self?.ref else {
        return
      }
        
      if peripheral.state != .connected {
        self?.cancelPeripheralConnection(peripheral.identifier)
      }
    }
  }

  private func cancelPeripheralConnection(_ uuid: UUID) {
    guard let peripheral = getPeripheral(uuid) else {
      return
    }
    
    if peripheral.state != CBPeripheralState.connected {
      self.manager.cancelPeripheralConnection(peripheral)
    }
  }

  private func disconnectAll() {
    let connected: [CBPeripheral] = manager.retrieveConnectedPeripherals(withServices: [
      Gatt.HeartRateMonitor
    ])
      
    for peripheral in connected {
      manager.cancelPeripheralConnection(peripheral)
    }
  }

  private func disconnect(_ uuid: UUID) {
    guard let peripheral = getPeripheral(uuid) else {
      return
    }

    if peripheral.state != .connected {
      return
    }

    manager.cancelPeripheralConnection(peripheral)
  }

  private func toggle(_ uuid: UUID) {
    guard let peripheral = getPeripheral(uuid) else {
      return
    }
    peripheral.state == .connected ? disconnect(uuid) : connect(uuid)
  }

  private func stopScan() {
    if !manager.isScanning {
      return
    }

    manager.stopScan()
      
    BluetoothScanStoppedEvent.trigger()
  }

  private func getPeripheral(_ uuid: UUID) -> CBPeripheral? {
    let peripherals: [CBPeripheral] = manager.retrievePeripherals(withIdentifiers: [uuid])

    guard let peripheral = peripherals.first else {
      return nil
    }

    return peripheral
  }
}

extension BluetoothService: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
      BluetoothServiceDidUpdateStateEvent(state: central.state).trigger()
      central.state == .poweredOn ? scan() : stopScan()
  }

  func centralManager(
    _: CBCentralManager, didDiscover peripheral: CBPeripheral,
    advertisementData _: [String: Any], rssi _: NSNumber
  ) {
      
      PeripheralDiscoveredEvent.from(peripheral).trigger()
      
    if User.current.heartRateMonitor == peripheral.identifier.uuidString {
      connect(peripheral.identifier)
    }
  }

  func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
      PeripheralConnectedEvent.from(peripheral).trigger()
    peripheral.discoverServices([Gatt.HeartRateMonitor])
  }

  func centralManager(
    _: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: Error?
  ) {

      PeripheralDisconnectedEvent.from(peripheral).trigger()
    if ref == peripheral {
      ref = nil
    }
  }
}

extension BluetoothService: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: Error?) {
    guard let services = peripheral.services else { return }
    for service in services {
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }

  func peripheral(
    _ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error _: Error?
  ) {

    guard let characteristics = service.characteristics else { return }

    guard
      let heartRateMeasurement = characteristics.first(where: {
        $0.uuid == Gatt.HeartRateMeasurment
      })
    else { return }
    peripheral.setNotifyValue(true, for: heartRateMeasurement)

  }

  func peripheral(
    _ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error _: Error?
  ) {
      guard let value = characteristic.value else { return }
      let sample = HeartRateMeasurementCharacteristic(value).sample
      PeripheralValueUpdatedEvent.from(peripheral).trigger(sample: sample)
  }
}
