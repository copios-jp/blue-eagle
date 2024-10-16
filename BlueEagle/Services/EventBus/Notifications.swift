import Foundation

/**
 Events

 The following are events published via the EventBus
 */

extension NSNotification.Name {
  static let BluetoothServiceDidUpdateState = NSNotification.Name(
    "bluetooth_service_did_update_state")
  static let BluetoothRequestScan = NSNotification.Name("bluetooth_request_scan")
  static let BluetoothScanStarted = NSNotification.Name("bluetooth_scan_started")
  static let BluetoothScanStopped = NSNotification.Name("bluetooth_scan_stopped")
  static let BluetoothRequestConnection = NSNotification.Name("bluetooth_request_connection")
  static let BluetoothRequestDisconnection = NSNotification.Name("bluetooth_request_disconnection")
  static let HeartRateMonitorDiscovered = NSNotification.Name("heart_rate_monitor_discovered")
  static let HeartRateMonitorConnected = NSNotification.Name("heart_rate_monitor_connected")
  static let HeartRateMonitorDead = NSNotification.Name("heart_rate_monitor_dead")
  static let HeartRateMonitorDisconnected = NSNotification.Name("heart_rate_monitor_disconnected")
  static let HeartRateMonitorValueUpdated = NSNotification.Name("heart_rate_monitor_value_updated")
}
