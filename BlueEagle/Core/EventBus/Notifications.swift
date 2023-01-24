//
//  Notifications.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/13.
//

import Foundation

extension NSNotification.Name {
  static let BluetoothRequestScan = NSNotification.Name("bluetooth_request_scan")
  static let BluetoothScanStarted = NSNotification.Name("bluetooth_scan_started")
  static let BluetoothScanStopped = NSNotification.Name("bluetooth_scan_stopped")
  static let BluetoothRequestConnection = NSNotification.Name("bluetooth_request_connection")
  
  static let BluetoothPeripheralConnected = NSNotification.Name("bluetooth_peripheral_connected")
  static let BluetoothRequestDisconnection = NSNotification.Name("bluetooth_request_disconnection")
  static let BluetoothPeripheralDisconnected = NSNotification.Name("bluetooth_peripheral_disconnected")
  
  static let BluetoothRequestToggle = NSNotification.Name("bluetooth_request_toggle")
  
  static let HeartRateMonitorDiscovered = NSNotification.Name("heart_rate_monitor_discovered")
  static let HeartRateMonitorConnected = NSNotification.Name("heart_rate_monitor_connected")
  static let HeartRateMonitorDead = NSNotification.Name("heart_rate_monitor_dead")
  static let HeartRateMonitorDisconnected = NSNotification.Name("heart_rate_monitor_disconnected")
  static let HeartRateMonitorValueUpdated = NSNotification.Name("heart_rate_monitor_value_updated")
}
