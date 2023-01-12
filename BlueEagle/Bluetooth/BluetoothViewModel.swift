//
//  BluetoothViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/12.
//

import CoreBluetooth
import Foundation

extension NSNotification.Name {
  static let BluetoothRequestScan = NSNotification.Name(rawValue: "bluetooth_request_scan")
  static let BluetoothRequestConnection = NSNotification.Name(rawValue: "bluetooth_request_connection")
  static let BluetoothRequestDisconnection = NSNotification.Name(rawValue: "bluetooth_request_disconnection")
}

// monitors bluetooth service notifications to provide view state
class BluetoothViewModel: NSObject, ObservableObject {
  @Published var receiving: Bool = false
  @Published var pulse: Bool = false
  @Published var isScanning: Bool = false
  @Published var peripherals = Set<CBPeripheral>()

  private var identicalReadingCount: Int = 0
  private var lastHeartRate: Int = 0
  private let DEAD_STICK_COUNT: Int = 30

  override init() {
    super.init()
    print("model init")
    NotificationCenter.default.addObserver(self, selector: #selector(heartRateReceived(notification:)), name: NSNotification.Name.BluetoothPeripheralValueUpdated, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(bluetoothScanStart(notification:)), name: NSNotification.Name.BluetoothScanStart, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(bluetoothScanStop(notification:)), name: NSNotification.Name.BluetoothScanStop, object: nil)

    // a peripherals model is likely to be better
    NotificationCenter.default.addObserver(self, selector: #selector(bluetoothPeripheralDiscovered(notification:)), name: NSNotification.Name.BluetoothPeripheralDiscoverd, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(bluetoothPeripheralConnected(notification:)), name: NSNotification.Name.BluetoothPeripheralConnected, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(bluetoothPeripheralDisconnected(notification:)), name: NSNotification.Name.BluetoothPeripheralDisconnected, object: nil)
  }

  func scan() {
    NotificationCenter.default.post(name: NSNotification.Name.BluetoothRequestScan, object: self)
  }

  func toggle(_ peripheral: CBPeripheral) {
    peripheral.state == CBPeripheralState.connected ? disconnect(peripheral) : connect(peripheral)
  }

  func connect(_ peripheral: CBPeripheral) {
    NotificationCenter.default.post(name: NSNotification.Name.BluetoothRequestConnection, object: self, userInfo: ["peripheral": peripheral])
  }

  func disconnect(_ peripheral: CBPeripheral) {
    NotificationCenter.default.post(name: NSNotification.Name.BluetoothRequestDisconnection, object: self, userInfo: ["peripheral": peripheral])
  }

  @objc func bluetoothScanStart(notification _: Notification) {
    print("scan start")
    isScanning = true
  }

  @objc func bluetoothScanStop(notification _: Notification) {
    print("scan stop")
    isScanning = false
  }

  @objc func bluetoothPeripheralDiscovered(notification: Notification) {
    let peripheral: CBPeripheral = notification.userInfo!["peripheral"] as! CBPeripheral
    peripherals.insert(peripheral)

    print("\(peripheral.identifier.uuidString) discovered")
    guard let preferred = Preferences.standard.heartRateMonitor else {
      connect(peripheral)
      return
    }

    if preferred == peripheral.identifier.uuidString {
      connect(peripheral)
    }
  }

  @objc func bluetoothPeripheralConnected(notification: Notification) {
    let peripheral: CBPeripheral = notification.userInfo!["peripheral"] as! CBPeripheral
    print("\(peripheral.identifier.uuidString) connected")
  }

  @objc func bluetoothPeripheralDisconnected(notification: Notification) {
    let peripheral: CBPeripheral = notification.userInfo!["peripheral"] as! CBPeripheral
    print("\(peripheral.identifier.uuidString) disconnected")
  }

  @objc func heartRateReceived(notification: Notification) {
    let heartRate: Int = notification.userInfo!["heart_rate_measurement"] as! Int
    identicalReadingCount = heartRate != lastHeartRate ? 0 : identicalReadingCount + 1

    receiving = identicalReadingCount < DEAD_STICK_COUNT

    if receiving {
      pulse.toggle()

      Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
        DispatchQueue.main.async {
          self.pulse.toggle()
        }
      }
    }

    lastHeartRate = heartRate
  }
}
