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
      return lhs.identifier == rhs.identifier
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
        print("view model state update", value, self.identifier, self.icon.systemName)
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
