//
//  File.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/28.
//
import Foundation
import SwiftUI

class Training: ObservableObject {
  
  private let observing: [Selector: NSNotification.Name] = [
    #selector(heartRateMonitorValueUpdated(notification:)): .HeartRateMonitorValueUpdated,
  ]

  private var samples: [HRSample] = []
  private var calorieCounter: CalorieCounter = .init()
  
  private (set) var startedAt: Date?
  private (set) var endedAt: Date?
     
  let uuid = UUID()
  
  @Published var currentHR: Double = 0.0
  
  var zone: TrainingZone = GarminTraining.zone(maxHR:1, heartRate: 0)
  
  
  var duration: DateComponents {
    get {
      let from = startedAt ?? Date()
      let to = endedAt ?? Date()
      
      return Calendar.current.dateComponents([.second, .minute, .hour], from: from, to: to)
    }
  }
 
  // TODO - allow this as a setting
  var restingHR: Double {
    get {
      50.0
    }
  }
 
  private (set) var averageHR: Double = 0.0
  
  var reserveHR: Double {
    get {
      maxHR - restingHR
    }
  }
 
  var percentOfMax: Double {
    get {
      Double(currentHR) / Double(maxHR)
    }
  }
  
  var percentOfReserve: Double {
    get {
      Double(currentHR - restingHR) / Double(reserveHR)
    }
  }
 
  // TODO - some kind of caching strategy or
  // incremental updating is this gets hit on
  // every heart rate sample and re-calculates
  // across all samples
 
  /*
  var calories: Double {
    get {
      calorieCounter.calories(samples)
    }
  }
  */
  
  var maxHR: Double {
    get {
      211.0 - 0.67 * Double(Preferences.standard.age)
    }
  }
  
  init(_ eventBus: EventBus = NotificationCenter.default) {
    eventBus.registerObservers(self, observing)
  }
  
  @objc private func heartRateMonitorValueUpdated(notification: Notification) {
    if startedAt == nil {
      startedAt = Date()
    }
    
    let heartRate: Double = notification.userInfo!["sample"] as! Double
    addSample(heartRate)
    
  }

  private func addSample(_ heartRate: Double, _ at: Date = Date()) {
    samples.append(HRSample(rate: heartRate, at: at))
    
    averageHR = averageHR + (heartRate - averageHR) / Double(samples.count)
    zone = GarminTraining.zone(maxHR: maxHR, heartRate: currentHR)
                                                                 
    currentHR = heartRate
  }
}
