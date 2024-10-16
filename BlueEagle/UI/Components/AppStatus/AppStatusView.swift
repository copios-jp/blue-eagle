//
//  AppStatusView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/10/15.
//

import CoreBluetooth
import SwiftUI

@MainActor internal struct AppStatusView: View {
  @StateObject var viewModel: AppStatusView.ViewModel = .init()

  internal var body: some View {
    Image(systemName: viewModel.systemName).foregroundColor(viewModel.color)
  }
}

extension AppStatusView {
  class ViewModel: ObservableObject, EventBusObserver {

    enum AppStates: Int {
      case offline
      case connected
      case scanning
      case dead
    }

    let observing: [Selector: [NSNotification.Name]] = [
      #selector(bluetoothServiceDidUpdateState(notification:)): [.BluetoothServiceDidUpdateState],
      #selector(bluetoothScanStarted(notification:)): [.BluetoothScanStarted],
      #selector(heartRateMonitorValueUpdated(notification:)): [.HeartRateMonitorValueUpdated],
      #selector(heartRateMonitorDisconnected(notification:)): [.HeartRateMonitorConnected],
    ]

    private(set) var identicalSampleCount: Int = 0
    private(set) var lastSample: Double = 0

    private(set) var state: AppStates = .offline {
      didSet {
        guard oldValue != state else { return }
        if state == .connected {
          identicalSampleCount = 0
        }
        switch state {
        case .offline:
          systemName = "antenna.radiowaves.left.and.right.slash"
          color = .red
        case .dead:
          systemName = "heart.slash"
          color = .secondary
        case .scanning:
          systemName = "antenna.radiowaves.left.and.right"
          color = .primary
        case .connected:
          systemName = "heart.fill"
          color = .primary
        }
      }
    }

    let MAX_IDENTICAL_HEART_RATE: Int = 30

    @Published private(set) var color: Color = .red
    @Published private(set) var systemName: String = "antenna.radiowaves.left.and.right.slash"

    init() {
      EventBus.addObserver(self)
    }

    deinit {
      EventBus.removeObserver(self)
    }

    private func isMine(_ notification: Notification) -> Bool {
      let notificationIdentifier = notification.userInfo!["identifier"] as! UUID
      return notificationIdentifier.uuidString == User.current.heartRateMonitor
    }

    private func validated(_ notification: Notification, _ proc: (_ sample: Double) -> Void) {
      if isMine(notification) {
        let sample: Double = notification.userInfo!["sample"] as! Double
        proc(sample)
      }
    }

    private func validated(_ notification: Notification, _ proc: () -> Void) {
      if isMine(notification) {
        proc()
      }
    }

    @objc private func bluetoothServiceDidUpdateState(notification: Notification) {
      let managerState = notification.userInfo!["state"] as! CBManagerState
      switch managerState {
      case .poweredOff, .unauthorized, .unsupported, .resetting, .unknown:
        state = .offline
      default: break
      }
    }

    @objc private func bluetoothScanStarted(notification: Notification) {
      state = .scanning
    }

    @objc private func heartRateMonitorDisconnected(notification: Notification) {
      validated(notification) {
        state = .dead
      }
    }

    @objc private func heartRateMonitorValueUpdated(notification: Notification) {
      validated(notification) { sample in
        identicalSampleCount = sample == lastSample ? identicalSampleCount + 1 : 0
        lastSample = sample

        state = identicalSampleCount > MAX_IDENTICAL_HEART_RATE ? .dead : .connected
      }
    }

  }
}

#Preview {
  AppStatusView()
}
