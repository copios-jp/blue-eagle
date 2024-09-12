//
//  HeartRateMonitorViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/17.
//

import Combine
import SwiftUI

class HeartRateMonitorViewModel: NSObject, ObservableObject, HeartRateMonitorDelegate {
    func sampleRecorded(_ value: Double) {
        print("sample")
    // TODO - change icon color then let it fade back
    }
    
    func connected() {
      print("HeartRateMonitorViewModel CONNECTED")
      icon = Self.LiveHeartRateMonitorIcon
    }
    
    func disconnected() {
      icon = Self.DeadHeartRateMonitorIcon
    }
  
    
  struct HeartRateMonitorIcon {
    var systemName: String
    var foregroundColor: Color
  }

  private static let LiveHeartRateMonitorIcon = HeartRateMonitorIcon(
    systemName: "heart.fill", foregroundColor: .primary)
  private static let DeadHeartRateMonitorIcon = HeartRateMonitorIcon(
    systemName: "heart.slash", foregroundColor: .secondary)

  static func == (lhs: HeartRateMonitorViewModel, rhs: HeartRateMonitorViewModel) -> Bool {
      return lhs.identifier == rhs.identifier
  }
  
  private var heartRateMonitor: HeartRateMonitor
    
  var identifier: UUID {
    heartRateMonitor.identifier
  }
    
  @Published var name: String = "Unknown"
  @Published var icon: HeartRateMonitorIcon
    
  init(_ heartRateMonitor: HeartRateMonitor) {
    self.heartRateMonitor = heartRateMonitor
    name = heartRateMonitor.name
    icon = Self.DeadHeartRateMonitorIcon
    super.init()
    heartRateMonitor.delegate = self
  }

  func toggle() {
    heartRateMonitor.toggle()
  }
}
