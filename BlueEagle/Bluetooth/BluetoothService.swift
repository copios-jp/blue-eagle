//
//  BluetoothService.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/21.
//
import CoreBluetooth
import Foundation

// MARK: - Bluetooth Service

/*

 I need to know

 State of central manager

 State of peripheral (connected/not found)

 Heart Rate

 */
let MAX_IDENTICAL_READING_COUNT = 10

extension NSNotification.Name {
  static let HeartRate = NSNotification.Name(rawValue: "heart_rate")
}

class BluetoothService: NSObject, ObservableObject {
  var centralManager: CBCentralManager?

  @Published var state: CBManagerState = .unknown
  @Published var peripherals = Set<CBPeripheral>()
  @Published var peripheral: CBPeripheral?

  @Published var receiving: Bool = false
  @Published var isScanning: Bool = false
  @Published var pulse: Bool = false

  private var identicalReadingCount: Int = 0
  private var lastHeartRate: Int = 0

  var manager: CBCentralManager {
    return centralManager!
  }

  var connected: [CBPeripheral] {
    return manager.retrieveConnectedPeripherals(withServices: [GATT.heartRate])
  }

  override init() {
    super.init()

    centralManager = CBCentralManager(delegate: self, queue: nil)
  }

  func scan(_ timeout: Double = 5.0) {
    if manager.state != CBManagerState.poweredOn {
      return
    }

    if manager.isScanning {
      stopScan()
    }

    manager.scanForPeripherals(withServices: [GATT.heartRate], options: nil)

    Timer.scheduledTimer(withTimeInterval: timeout, repeats: false) { _ in
      DispatchQueue.main.async {
        self.stopScan()
      }
    }

    isScanning = manager.isScanning
  }

  func stopScan() {
    if manager.isScanning {
      manager.stopScan()
    }
    isScanning = manager.isScanning
  }

  func connect(_ peripheral: CBPeripheral) {
    connected.forEach(disconnect)
    self.peripheral = peripheral
    peripheral.delegate = self
    manager.connect(peripheral)
  }

  func disconnect(_ peripheral: CBPeripheral) {
    peripheral.delegate = nil
    manager.cancelPeripheralConnection(peripheral)
  }

  func onHeartRateReceived(_ inHeartRate: Int) {
    identicalReadingCount = inHeartRate != lastHeartRate ? 0 : identicalReadingCount + 1

    receiving = identicalReadingCount < MAX_IDENTICAL_READING_COUNT

    NotificationCenter.default.post(name: NSNotification.Name.HeartRate, object: self, userInfo: ["heart_rate": inHeartRate])

    pulse.toggle()

    Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
      DispatchQueue.main.async {
        self.pulse.toggle()
      }
    }

    lastHeartRate = inHeartRate
  }
}

// MARK: CBCentralManagerDelegate

extension BluetoothService: CBCentralManagerDelegate {
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == CBManagerState.poweredOn {
      scan()
    }
  }

  func centralManager(_: CBCentralManager, didDiscover peripheral: CBPeripheral,
                      advertisementData _: [String: Any], rssi _: NSNumber)
  {
    peripherals.insert(peripheral)

    // no preference so let's connect the first one, establishing a preference
    guard let preferred = Preferences.standard.heartRateMonitor else {
      connect(peripheral)
      return
    }

    if preferred == peripheral.identifier.uuidString {
      connect(peripheral)
    }
  }

  func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
    let otherPeripherals = connected.filter { $0.identifier != peripheral.identifier }
    otherPeripherals.forEach(disconnect)

    peripheral.delegate = self
    self.peripheral = peripheral
    peripheral.discoverServices([GATT.heartRate])

    Preferences.standard.heartRateMonitor = peripheral.identifier.uuidString
  }

  func centralManager(_: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: Error?) {
    peripheral.delegate = nil
    guard let current = self.peripheral else {
      return
    }

    if current == peripheral {
      receiving = false
      self.peripheral = nil
    }
  }
}

// MARK: CBPeripheralDelegate

extension BluetoothService: CBPeripheralDelegate {
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices _: Error?) {
    guard let services = peripheral.services else { return }
    for service in services {
      peripheral.discoverCharacteristics(nil, for: service)
    }
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error _: Error?) {
    guard let characteristics = service.characteristics else { return }

    for characteristic in characteristics {
      if characteristic.properties.contains(.notify) {
        peripheral.setNotifyValue(true, for: characteristic)
      }
    }
  }

  func peripheral(_: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error _: Error?) {
    if characteristic.uuid != GATT.heartRateMeasurement {
      return
    }

    let bpm = heartRate(from: characteristic)
    onHeartRateReceived(bpm)
  }

  private func heartRate(from characteristic: CBCharacteristic) -> Int {
    guard let characteristicData = characteristic.value else { return -1 }
    let byteArray = [UInt8](characteristicData)

    // org.bluetooth.characteristic.heart_rate_measurement.xml
    let firstBitValue = byteArray[0] & 1

    var rate = Int(byteArray[1])

    if firstBitValue == 1 {
      rate = (rate << 8) + Int(byteArray[2])
    }

    return rate
  }
}
