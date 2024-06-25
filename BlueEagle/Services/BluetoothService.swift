//
//  BluetoothService.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/21.
//
import CoreBluetooth
import Foundation

// MARK: - Bluetooth Service

protocol BluetoothHeartRateMonitorService: CBManager {
  var delegate: CBCentralManagerDelegate? { get set }
  var isScanning: Bool { get }

  func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String: Any]?)
  func connect(_ peripheral: CBPeripheral, options: [String: Any]?)
  func cancelPeripheralConnection(_ peripheral: CBPeripheral)
  func retrievePeripherals(withIdentifiers: [UUID]) -> [CBPeripheral]
  func retrieveConnectedPeripherals(withServices: [CBUUID]) -> [CBPeripheral]
  func stopScan()
}

extension CBCentralManager: BluetoothHeartRateMonitorService {}

class BluetoothService: NSObject {
  private struct GATT {
    // peripheral
    static let heartRateMonitor: CBUUID = CBUUID(string: "0x180D")

    // characteristic
    static let heartRateMeasurement: CBUUID = CBUUID(string: "2A37")
    static let bodySensorLocation: CBUUID = CBUUID(string: "2A38")
  }

  private var eventBus: EventBus
  private var manager: BluetoothHeartRateMonitorService

  private var observing: [Selector: NSNotification.Name] = [
    #selector(bluetoothRequestScan(notification:)): .BluetoothRequestScan,
    #selector(bluetoothRequestConnection(notification:)): .BluetoothRequestConnection,
    #selector(bluetoothRequestDisconnection(notification:)): .BluetoothRequestDisconnection,
    #selector(bluetoothRequestToggle(notification:)): .BluetoothRequestToggle,
  ]

  override convenience init() {
    self.init(NotificationCenter.default)
  }

  init(
    _ eventBus: EventBus = NotificationCenter.default,
    manager: BluetoothHeartRateMonitorService = CBCentralManager()
  ) {
    self.eventBus = eventBus
    self.manager = manager
    super.init()

    self.eventBus.registerObservers(self, observing)
    self.manager.delegate = self
  }

  @objc func bluetoothRequestScan(notification _: Notification) {
    scan()
  }

  func scan(_ timeout: Double = 5.0) {
    if manager.state != CBManagerState.poweredOn || manager.isScanning {
      return
    }

    eventBus.trigger(.BluetoothScanStarted)

    manager.scanForPeripherals(withServices: [GATT.heartRateMonitor], options: nil)

    Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
      DispatchQueue.main.async {
        self.stopScan()
      }
    }
  }

  @objc func bluetoothRequestConnection(notification: Notification) {
    let identifier: UUID = notification.userInfo!["identifier"] as! UUID
    connect(identifier)
  }

  @objc func bluetoothRequestDisconnection(notification: Notification) {
    let identifier: UUID = notification.userInfo!["identifier"] as! UUID
    disconnect(identifier)
  }

  @objc func bluetoothRequestToggle(notification: Notification) {
    let identifier: UUID = notification.userInfo!["identifier"] as! UUID
    toggle(identifier)
  }

  func connect(_ uuid: UUID, _ timeout: Double = 5.0) {
    print("connect", uuid)
    let peripherals: [CBPeripheral] = manager.retrievePeripherals(withIdentifiers: [uuid])
    guard let peripheral = peripherals.first else {
      return
    }

    if peripheral.state == .connected {
      return
    }

    disconnectAll()
    peripheral.delegate = self
    manager.connect(peripheral, options: nil)

    Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
      DispatchQueue.main.async {
        if peripheral.state != CBPeripheralState.connected {
          self.manager.cancelPeripheralConnection(peripheral)
        }
      }
    }
  }

  func disconnectAll() {
    let connected: [CBPeripheral] = manager.retrieveConnectedPeripherals(withServices: [
      GATT.heartRateMonitor
    ])
    for peripheral in connected {
      manager.cancelPeripheralConnection(peripheral)
    }
  }

  func disconnect(_ uuid: UUID) {
    print("disconnect", uuid)
    let peripherals: [CBPeripheral] = manager.retrievePeripherals(withIdentifiers: [uuid])
    guard let peripheral = peripherals.first else {
      return
    }

    if peripheral.state != .connected {
      return
    }

    manager.cancelPeripheralConnection(peripheral)
  }

  func toggle(_ uuid: UUID) {
    let peripherals: [CBPeripheral] = manager.retrievePeripherals(withIdentifiers: [uuid])
    guard let peripheral = peripherals.first else {
      return
    }
    peripheral.state == .connected ? disconnect(uuid) : connect(uuid)
  }

  func stopScan() {
    if !manager.isScanning {
      return
    }

    manager.stopScan()

    eventBus.trigger(.BluetoothScanStopped)
  }
}

extension BluetoothService: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == CBManagerState.poweredOn {
      scan()
    }
  }

  func centralManager(
    _: CBCentralManager, didDiscover peripheral: CBPeripheral,
    advertisementData _: [String: Any], rssi _: NSNumber
  ) {

    print("disovered", peripheral.name!)
    eventBus.trigger(
      .HeartRateMonitorDiscovered, ["name": peripheral.name!, "identifier": peripheral.identifier])
  }

  func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
    peripheral.discoverServices([GATT.heartRateMonitor])
    print("CentralManager connected")
    eventBus.trigger(.HeartRateMonitorConnected, ["identifier": peripheral.identifier])
  }

  func centralManager(
    _: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: Error?
  ) {
    eventBus.trigger(.HeartRateMonitorDisconnected, ["identifier": peripheral.identifier])
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
        $0.uuid == GATT.heartRateMeasurement
      })
    else { return }

    peripheral.setNotifyValue(true, for: heartRateMeasurement)
  }

  func peripheral(
    _ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error _: Error?
  ) {
    let heartRate = heartRate(from: characteristic)

    let userInfo: [AnyHashable: AnyHashable] = [
      "identifier": peripheral.identifier,
      "sample": heartRate,
    ]

    eventBus.trigger(.HeartRateMonitorValueUpdated, userInfo)
  }

  private func heartRate(from characteristic: CBCharacteristic) -> Double {
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)

    // org.bluetooth.characteristic.heart_rate_measurement.xml
    let firstBitValue = byteArray[0] & 1

    var rate = Int(byteArray[1])

    if firstBitValue == 1 {
      rate = (rate << 8) + Int(byteArray[2])
    }

    return Double(rate)
  }
}

extension BluetoothService {
  struct Peripheral {
    var name: String
    var identifier: UUID
  }
}
