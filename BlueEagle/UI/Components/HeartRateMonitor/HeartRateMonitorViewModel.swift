//
//  HeartRateMonitorViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/17.
//

import Combine
import SwiftUI

class HeartRateMonitorViewModel: NSObject, ObservableObject {

  private var heartRateMonitor: HeartRateMonitor
    
  var identifier: UUID {
    heartRateMonitor.identifier
  }
    
  @Published var name: String = "Unknown"
  @Published var systemName: String =  "heart.slash"
  @Published var foregroundColor: Color =  .secondary
    
  init(_ heartRateMonitor: HeartRateMonitor) {
    self.heartRateMonitor = heartRateMonitor
    name = heartRateMonitor.name
    super.init()
    heartRateMonitor.delegate = self
  }

  func toggle() {
    heartRateMonitor.toggle()
  }
}
extension HeartRateMonitorViewModel: HeartRateMonitorDelegate {
     func sampleRecorded(_ value: Double) {
        print("sample")
    // TODO - change icon color then let it fade back
    }
    
    func connected() {
      print("HeartRateMonitorViewModel CONNECTED")
        systemName = "heart.fill"
        foregroundColor = .primary
    }
    
    func disconnected() {
        systemName = "heart.slash"
        foregroundColor = .secondary
    }
  

}
