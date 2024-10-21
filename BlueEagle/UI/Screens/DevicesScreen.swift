import CoreBluetooth
import SwiftUI

@MainActor internal struct DevicesScreen: View {
  @StateObject var viewModel: DevicesScreen.ViewModel = .init()

  var body: some View {
    VStack {
      if viewModel.items.isEmpty {
        Text("No Devices")
      }
      List {
        ForEach(viewModel.items, id: \.self) { monitorViewModel in
          let gesture = TapGesture().onEnded { monitorViewModel.toggle() }

          HeartRateMonitorView(viewModel: monitorViewModel)
            .gesture(gesture)
        }
      }
      if viewModel.isScanning {
        loadingView
      } else {
        scanButton
      }
    }
    .onAppear(perform: scan)
    .navigationTitle("Heart Rate Monitors")
  }

  private func scan() {
    BluetoothRequestScanEvent.trigger()
  }
}

extension DevicesScreen {
  fileprivate var loadingView: some View {
    ProgressView()
  }

  fileprivate var scanButton: some View {
    Button("scan") { scan() }
  }
}

extension DevicesScreen {
  class ViewModel: ObservableObject, EventBusObserver {

    let observing: [Selector: [NSNotification.Name]] = [
      #selector(bluetoothScanStarted(notification:)): [.BluetoothScanStarted],
      #selector(bluetoothScanStopped(notification:)): [.BluetoothScanStopped],
      #selector(heartRateMonitorDiscovered(notification:)): [.HeartRateMonitorDiscovered],
      #selector(heartRateMonitorConnected(notification:)): [.HeartRateMonitorConnected],
    ]

    @Published private(set) var isScanning: Bool = false
    @Published private(set) var items: [HeartRateMonitorViewModel]

    init(items: [HeartRateMonitorViewModel] = []) {
      self.items = items
      EventBus.addObserver(self)
    }

    deinit {
      EventBus.removeObserver(self)
    }

    func add(_ name: String, _ identifier: UUID) {
      if items.contains(where: { $0.identifier == identifier }) {
        return
      }

      let model = HeartRateMonitor(name: name, identifier: identifier)
      let viewModel = HeartRateMonitorViewModel(model)

      items.append(viewModel)
    }

    @objc func bluetoothScanStarted(notification _: Notification) {
      isScanning = true
    }

    @objc func bluetoothScanStopped(notification _: Notification) {
      isScanning = false
    }

    @objc func heartRateMonitorDiscovered(notification: Notification) {
        let event = notification.object as! PeripheralEvent
        add(event.label, event.identifier)

        if User.current.heartRateMonitor == event.identifier.uuidString {
            BluetoothRequestConnectionEvent.trigger(identifier: event.identifier)
        }
    }

    @objc func heartRateMonitorConnected(notification: Notification) {
        let event = notification.object as! PeripheralEvent
        User.current.heartRateMonitor = event.identifier.uuidString
    }
  }
}

// MARK: Preview

#Preview {
  let monitor = HeartRateMonitor(name: "Preview Monitor")
  let monitorViewModel: HeartRateMonitorViewModel = .init(monitor)
  let viewModel: DevicesScreen.ViewModel = .init(items: [monitorViewModel])

  DevicesScreen(viewModel: viewModel)
}
