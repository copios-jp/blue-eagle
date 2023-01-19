//
//  HeartRateMonitorListViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/17.
//

import Foundation
import Combine

// MARK: ViewModel

extension HeartRateMonitorList {
  class ViewModel: ObservableObject {
    private var eventBus: EventBus
    
    private var observing: [Selector: NSNotification.Name] = [
      #selector(bluetoothScanStarted(notification:)): .BluetoothScanStarted,
      #selector(bluetoothScanStopped(notification:)): .BluetoothScanStopped,
      #selector(heartRateMonitorDiscovered(notification:)): .HeartRateMonitorDiscoverd,
      #selector(heartRateMonitorConnected(notification:)): .HeartRateMonitorConnected,
    ]
    
    @Published private (set) var isScanning: Bool = false
    @Published private(set) var items: [HeartRateMonitorViewModel]
    @Published private (set) var current: HeartRateMonitorViewModel?
        
    init(items: [HeartRateMonitorViewModel] = [], _ eventBus: EventBus = NotificationCenter.default) {
      self.eventBus = eventBus
      self.items = items
      self.eventBus.registerObservers(self, observing)
    }
    
    func scan() {
      eventBus.trigger(.BluetoothRequestScan)
    }
    
    @objc func bluetoothScanStarted(notification _: Notification) {
      isScanning = true
    }
    
    @objc func bluetoothScanStopped(notification _: Notification) {
      isScanning = false
    }
    
    @objc func heartRateMonitorDiscovered(notification: Notification) {
      let identifier: UUID = notification.userInfo!["identifier"] as! UUID
      let name: String = notification.userInfo!["name"] as! String
      
      if items.first(where: { $0.identifier == identifier }) != nil {
        return  // we already know about this device
      }
      
      let model = HeartRateMonitor(name: name, identifier: identifier)
      let viewModel = HeartRateMonitorViewModel(model, eventBus: eventBus)
      items.append(viewModel)
      
      @Preference(\.heartRateMonitor) var preferredDevice
      
      if preferredDevice == nil || preferredDevice == identifier.uuidString {
        model.connect()
      }
    }
    
    @objc func heartRateMonitorConnected(notification: Notification) {
      let identifier: UUID = notification.userInfo!["identifier"] as! UUID
      
      guard let monitor = items.first(where: { $0.identifier == identifier }) else {
        return // unknwon device connection detected
      }
      
      Preferences.standard.heartRateMonitor = identifier.uuidString
      current = monitor
    }
  }
}

