//
//  HeartRateMonitorViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/17.
//

import SwiftUI
import Combine

class HeartRateMonitorViewModel: ObservableObject, Hashable, Equatable {
  struct HeartRateMonitorIcon {
    var systemName: String
    var foregroundColor: Color
  }
  
  static let LiveHeartRateMonitorIcon = HeartRateMonitorIcon(systemName: "heart.fill", foregroundColor: .primary)
  static let DeadHeartRateMonitorIcon = HeartRateMonitorIcon(systemName: "heart.slash", foregroundColor: .secondary)
  static func == (lhs: HeartRateMonitorViewModel, rhs: HeartRateMonitorViewModel) -> Bool {
    return lhs.identifier == rhs.identifier
  }
  
  private var heartRateMonitor: HeartRateMonitorDelegate
  private var cancellableModelState: AnyCancellable?
  
  @Published var name: String = "Unknown"
  @Published var icon: HeartRateMonitorIcon
  @Published var identifier: UUID = .init()

  init(_ heartRateMonitor: HeartRateMonitorDelegate, eventBus _: EventBus = NotificationCenter.default) {
    self.heartRateMonitor = heartRateMonitor
    name = heartRateMonitor.name
    identifier = heartRateMonitor.identifier
    icon = Self.DeadHeartRateMonitorIcon
    cancellableModelState = heartRateMonitor.statePublisher.sink { self.updateIconOnStateChange($0) }
  }
 
  private func updateIconOnStateChange(_ state: HeartRateMonitorState) {
    icon = state == .connected ? Self.LiveHeartRateMonitorIcon : Self.DeadHeartRateMonitorIcon
  }
   
  func toggle() {
    heartRateMonitor.toggle()
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(identifier)
  }
}

