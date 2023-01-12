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

extension NSNotification.Name {
  static let BluetoothScanStart = NSNotification.Name(rawValue: "bluetooth_scan_start")
  static let BluetoothScanStop = NSNotification.Name(rawValue: "bluetooth_scan_stop")
  static let BluetoothPeripheralDiscoverd = NSNotification.Name(rawValue: "bluetooth_peripheral_discovered")
  static let BluetoothPeripheralConnected = NSNotification.Name(rawValue: "bluetooth_peripheral_connected")
  static let BluetoothPeripheralValueUpdated = NSNotification.Name(rawValue: "bluetooth_peripheral_value_updated")

  static let BluetoothPeripheralDisconnected = NSNotification.Name(rawValue: "bluetooth_peripheral_disconnected")
}

class BluetoothService: NSObject, ObservableObject {
  var centralManager: CBCentralManager?

  @Published var state: CBManagerState = .unknown
  @Published var peripherals = Set<CBPeripheral>()
  @Published var peripheral: CBPeripheral?

  var manager: CBCentralManager {
    return centralManager!
  }

  var connected: [CBPeripheral] {
    return manager.retrieveConnectedPeripherals(withServices: [GATT.heartRate])
  }

  override init() {
    super.init()

    NotificationCenter.default.addObserver(self, selector: #selector(bluetoothRequestScan(notification:)), name: NSNotification.Name.BluetoothRequestScan, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(bluetoothRequestConnection(notification:)), name: NSNotification.Name.BluetoothRequestConnection, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(bluetoothRequestDisconnection(notification:)), name: NSNotification.Name.BluetoothRequestDisconnection, object: nil)

    centralManager = CBCentralManager(delegate: self, queue: nil)
  }

  @objc func bluetoothRequestScan(notification _: Notification) {
    scan()
  }

  @objc func bluetoothRequestConnection(notification: Notification) {
    let peripheral: CBPeripheral = notification.userInfo!["peripheral"] as! CBPeripheral
    peripheral.delegate = self
    manager.connect(peripheral)
  }

  @objc func bluetoothRequestDisconnection(notification: Notification) {
    let peripheral: CBPeripheral = notification.userInfo!["peripheral"] as! CBPeripheral
    peripheral.delegate = nil
    manager.cancelPeripheralConnection(peripheral)
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

    NotificationCenter.default.post(name: NSNotification.Name.BluetoothScanStart, object: self)
  }

  func stopScan() {
    if manager.isScanning {
      manager.stopScan()
    }

    NotificationCenter.default.post(name: NSNotification.Name.BluetoothScanStop, object: self)
  }

  /*
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

    */
  func onHeartRateReceived(_ inHeartRate: Int) {
    NotificationCenter.default.post(name: NSNotification.Name.BluetoothPeripheralValueUpdated, object: self, userInfo: ["heart_rate": inHeartRate])
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
    // peripherals.insert(peripheral)

    NotificationCenter.default.post(name: NSNotification.Name.BluetoothPeripheralDiscoverd, object: self, userInfo: ["peripheral": peripheral])
    /*
     // no preference so let's connect the first one, establishing a preference
     guard let preferred = Preferences.standard.heartRateMonitor else {
       connect(peripheral)
       return
     }

     if preferred == peripheral.identifier.uuidString {
       connect(peripheral)
     }
     */
  }

  func centralManager(_: CBCentralManager, didConnect peripheral: CBPeripheral) {
    /*
       let otherPeripherals = connected.filter { $0.identifier != peripheral.identifier }
       otherPeripherals.forEach(disconnect)
       peripheral.delegate = self
       self.peripheral = peripheral

     */
    peripheral.discoverServices([GATT.heartRate])

    Preferences.standard.heartRateMonitor = peripheral.identifier.uuidString

    NotificationCenter.default.post(name: NSNotification.Name.BluetoothPeripheralConnected, object: self, userInfo: ["peripheral": peripheral])
  }

  func centralManager(_: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error _: Error?) {
    peripheral.delegate = nil
    /*
     guard let current = self.peripheral else {
       return
     }

     if current == peripheral {
       self.peripheral = nil
     }
     */
    NotificationCenter.default.post(name: NSNotification.Name.BluetoothPeripheralDisconnected, object: self, userInfo: ["peripheral": peripheral])
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
    NotificationCenter.default.post(name: NSNotification.Name.BluetoothPeripheralValueUpdated, object: self, userInfo: ["uuid": characteristic.uuid, "heart_rate_measurement": bpm])

    // onHeartRateReceived(bpm)
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
