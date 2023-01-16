//
//  BluetoothView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/26.
//

import SwiftUI
import Combine

struct HeartRateMonitorList: View {
  @StateObject var model: ViewModel = .init()
  @State private var show: Bool = false
    
  var body: some View {
    HeartIcon(model: model.current)
      .onTapGesture { self.show = true }
      .sheet(isPresented: $show) {
        NavigationView {
          VStack {
            if model.isScanning {
              ProgressView()
            } else {
              if model.heartRateMonitors.count == 0 {
                Text("no sensors available")
              }
              List {
                ForEach(model.heartRateMonitors, id: \.self) { monitor in
                  HStack {
                    Text(monitor.name).font(.body)
                    Spacer()
                    HeartIcon(model: monitor)
                  }
                  .onTapGesture { monitor.toggle() }
                }
              }
            }
            Spacer()
            Button("scan") { model.scan() }
          }
          .navigationTitle("devices")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .confirmationAction) {
              Button("done") { self.show = false }
            }
          }
        }
      }
      .padding()
  }
}

// MARK: Preview

struct HeartRateMonitorList_Previews: PreviewProvider {
  static var previews: some View {
    HeartRateMonitorList()
  }
}

// MARK: HeartIcon

extension HeartRateMonitorList {
  struct HeartIcon: View {
    @ObservedObject var model: HeartRateMonitorList.HeartRateMonitorViewModel

    var body: some View {
      Image(systemName: model.icon.systemName)
        // .onTapGesture { self.show = true }
        .foregroundStyle(model.icon.foregroundStyle)
        .padding()
    }
  }
}

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

    @Published var isScanning: Bool = false
    @Published var heartRateMonitors: [HeartRateMonitorViewModel] = []
    @Published var current: HeartRateMonitorViewModel = .init(HeartRateMonitor(name: "none"))

    init(_ eventBus: EventBus = NotificationCenter.default) {
      self.eventBus = eventBus
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
      let monitor: HeartRateMonitor = notification.userInfo!["heartRateMonitor"] as! HeartRateMonitor
      let identifier = monitor.identifier
      let viewModel = HeartRateMonitorViewModel(monitor)
      @Preference(\.heartRateMonitor) var preferredDevice

      if heartRateMonitors.first(where: { $0.identifier == identifier }) == nil {
        heartRateMonitors.append(viewModel)
      }

      if preferredDevice == nil || preferredDevice == identifier.uuidString {
        monitor.connect()
      }
    }

    @objc func heartRateMonitorConnected(notification: Notification) {
      let identifier: UUID = notification.userInfo!["identifier"] as! UUID
      guard let monitor = heartRateMonitors.first(where: { $0.identifier == identifier }) else {
        return
      }

      Preferences.standard.heartRateMonitor = identifier.uuidString
      current = monitor
    }
  }
}

// MARK: HeartRateMonitorViewModel

extension HeartRateMonitorList {
  class HeartRateMonitorViewModel: ObservableObject, Hashable, Equatable {
    struct HeartRateMonitorIcon {
      var systemName: String
      var foregroundStyle: HierarchicalShapeStyle
    }

    private let LiveHeartRateMonitorIcon = HeartRateMonitorIcon(systemName: "heart.fill", foregroundStyle: .primary)
    private let DeadHeartRateMonitorIcon = HeartRateMonitorIcon(systemName: "heart.slash", foregroundStyle: .secondary)

    private var model: HeartRateMonitor
    private var cancellableModelState: AnyCancellable?

    @Published var name: String = "Unknown"
    @Published var icon: HeartRateMonitorIcon
    @Published var identifier: UUID = .init()

    static func == (lhs: HeartRateMonitorViewModel, rhs: HeartRateMonitorViewModel) -> Bool {
      return lhs.model.name == rhs.model.name
    }

    func hash(into hasher: inout Hasher) {
      hasher.combine(model.identifier)
    }

    init(_ heartRateMonitor: HeartRateMonitor, eventBus _: EventBus = NotificationCenter.default) {
      model = heartRateMonitor

      name = heartRateMonitor.name
      identifier = heartRateMonitor.identifier
      icon = DeadHeartRateMonitorIcon

      cancellableModelState = heartRateMonitor.$state.sink { value in
        self.icon = value == .connected ? self.LiveHeartRateMonitorIcon : self.DeadHeartRateMonitorIcon
      }
    }

    func connect() {
      model.connect()
    }

    func disconnect() {
      model.disconnect()
    }

    func toggle() {
      model.toggle()
    }
  }
}
