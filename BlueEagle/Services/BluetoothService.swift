//
//  BluetoothService.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/21.
//
import CoreBluetooth
import Foundation

// MARK: - Bluetooth Service

// http://bluetooth.com
struct Gatt {
  static let HeartRateMonitor = CBUUID(string: "0x180D")
  static let HeartRateMeasurment = CBUUID(string: "2A37")
}

class BluetoothService: NSObject {

  private let manager: CBCentralManager = CBCentralManager()

  private var ref: CBPeripheral?

  private var observing: [Selector: NSNotification.Name] = [
    #selector(bluetoothRequestScan(notification:)): .BluetoothRequestScan,
    #selector(bluetoothRequestConnection(notification:)): .BluetoothRequestConnection,
    #selector(bluetoothRequestDisconnection(notification:)): .BluetoothRequestDisconnection,
    #selector(bluetoothRequestToggle(notification:)): .BluetoothRequestToggle,
  ]

  override init() {
    super.init()

    EventBus.registerObservers(self, observing)
    manager.delegate = self
  }

  @objc func bluetoothRequestScan(notification _: Notification) {
    scan()
  }

  func scan(_ timeout: Double = 5.0) {
    if manager.state != CBManagerState.poweredOn || manager.isScanning {
      return
    }

    manager.scanForPeripherals(withServices: [Gatt.HeartRateMonitor], options: nil)
    EventBus.trigger(.BluetoothScanStarted)

    Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) {
      [weak self] _ in
      self?.stopScan()
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
    guard let peripheral = getPeripheral(uuid) else {
      return
    }
    ref = peripheral
    peripheral.delegate = self

    disconnectAll()
    manager.connect(peripheral, options: nil)

    Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) {
      [weak self] _ in

      guard let peripheral = self?.ref else {
        return
      }
      if peripheral.state != .connected {
        self?.cancelPeripheralConnection(peripheralID: peripheral.identifier)
      }
    }
  }

  func cancelPeripheralConnection(peripheralID: UUID) {
    guard let target = self.manager.retrievePeripherals(withIdentifiers: [peripheralID]).first
    else {
      return
    }
    if target.state != CBPeripheralState.connected {
      self.manager.cancelPeripheralConnection(target)
    }
  }

  func disconnectAll() {
    let connected: [CBPeripheral] = manager.retrieveConnectedPeripherals(withServices: [
      Gatt.HeartRateMonitor
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

    EventBus.trigger(.BluetoothScanStopped)
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
    if central.state == CBManagerState.poweredOn {
      self.scan()
    }
  }

  func centralManager(
    _: CBCentralManager, didDiscover peripheral: CBPeripheral,
    advertisementData _: [String: Any], rssi _: NSNumber
  ) {

    print("disovered", peripheral.name!)
    let name = peripheral.name
    let identifier = peripheral.identifier
    EventBus.trigger(.HeartRateMonitorDiscovered, ["name": name, "identifier": identifier])
  }

  func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
    EventBus.trigger(.HeartRateMonitorConnected, ["identifier": peripheral.identifier])
    peripheral.discoverServices([Gatt.HeartRateMonitor])
  }

  func centralManager(
    _: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: Error?
  ) {
    EventBus.trigger(.HeartRateMonitorDisconnected, ["identifier": peripheral.identifier])
  }
}

extension BluetoothService: CBPeripheralDelegate {
  nonisolated func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: Error?) {
    guard let services = peripheral.services else { return }
    for service in services {
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }

  nonisolated func peripheral(
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
    guard let characteristicData = characteristic.value else { return }
      print(characteristic.properties)
    let sample = HeartRateMeasurementCharacteristic(peripheral.identifier, characteristicData)

    EventBus.trigger(
      .HeartRateMonitorValueUpdated, ["sample": sample.value, "identifier": sample.peripheralId]
    )
  }
}

struct HeartRateMeasurementCharacteristic {
  enum DataFormat {
    case uInt8
    case uInt16
  }

  enum SensorStatus {
    case unsupported
    case good
    case poor
  }

  private let data: [UInt8]
  let uuid: UUID = .init()
  let peripheralId: UUID
  let format: DataFormat
  let sensorStatus: SensorStatus
  let rrIntervals: [Int]?
  let energyExpended: Int?
  let value: Double

  init(_ identifier: UUID, _ payload: Data) {

    peripheralId = identifier
    data = [UInt8](payload)

    let flags = data[0]
    format = (flags & (1 << 0)) == 0 ? .uInt8 : .uInt16

    let hasSensorStatus = (flags & (1 << 2)) != 0
    let hasEnergyExpended = (flags & (1 << 3)) != 0
    let hasRRIntervals = (flags & (1 << 4)) != 0

    if hasSensorStatus {
      sensorStatus = (flags & (1 << 1)) == 0 ? .poor : .good
    } else {
      sensorStatus = .unsupported
    }

    var pointer = 1

    if format == .uInt8 {
      value = Double(data[pointer])
    } else {
      var partial = Double(data[pointer])
      pointer += 1
      value = partial + Double(Int(data[pointer]) << 8)
    }

    pointer += 1

    if hasEnergyExpended {
      var partial = Int(data[pointer])
      pointer += 1
      energyExpended  = partial + (Int(data[pointer]) << 8)
      pointer += 1
    } else {
        energyExpended = nil
    }

    if pointer < data.count - 1 {
        var intervals: [Int] = []
      for pointer in stride(from: pointer, to: data.count - 1, by: 2) {
        let interval = Int(data[pointer]) + (Int(data[pointer + 1]) << 8)
        intervals.append(interval)
      }
      rrIntervals = intervals
    } else {
        rrIntervals = nil
    }
  }
}
