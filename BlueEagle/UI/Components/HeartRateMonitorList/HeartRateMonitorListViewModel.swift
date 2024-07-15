//
//  HeartRateMonitorListViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/17.
//

import Combine
import Foundation

// MARK: ViewModel

extension HeartRateMonitorListView {
  class ViewModel: ObservableObject {
    private var eventBus: EventBus

    private var observing: [Selector: NSNotification.Name] = [
      #selector(bluetoothScanStarted(notification:)): .BluetoothScanStarted,
      #selector(bluetoothScanStopped(notification:)): .BluetoothScanStopped,

      #selector(heartRateMonitorDiscovered(notification:)): .HeartRateMonitorDiscovered,
      #selector(heartRateMonitorConnected(notification:)): .HeartRateMonitorConnected,
    ]

    @Published private(set) var isScanning: Bool = false
    @Published private(set) var items: [HeartRateMonitorViewModel]
    @Published var current: HeartRateMonitorViewModel?

    init(items: [HeartRateMonitorViewModel] = [], eventBus: EventBus = NotificationCenter.default) {
      self.eventBus = eventBus
      self.items = items
      self.eventBus.registerObservers(self, observing)
    }

    func scan() {
      // TODO: consider flushing list of items on scan as we may have some
      // items listed that are not longer 'connectable' when the user leaves
      // the app open
      eventBus.trigger(.BluetoothRequestScan)
    }

    func add(_ name: String, _ identifier: UUID) {
      if items.contains(where: { $0.identifier == identifier }) {
        return
      }

      let model = HeartRateMonitor(name: name, identifier: identifier, eventBus: eventBus)
      let viewModel = HeartRateMonitorViewModel(model, eventBus: eventBus)
      items.append(viewModel)

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

      add(name, identifier)


      if User.current.heartRateMonitor == identifier.uuidString {
        eventBus.trigger(.BluetoothRequestConnection, ["identifier": identifier])
      }
    }

    @objc func heartRateMonitorConnected(notification: Notification) {
      let identifier: UUID = notification.userInfo!["identifier"] as! UUID
      guard let item = items.first(where: { $0.identifier == identifier }) else {
        return

      }

      current = item
      User.current.heartRateMonitor = identifier.uuidString
    }
  }
}
