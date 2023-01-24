//
//  TrainingZone.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/28.
//
import Foundation

struct TrainingZone {
  var maxHRPercent: Double
  var description: String
  var position: Int
  var minHR: Double
  var maxHR: Double
  var currentPercentOfHRMax: Double = 0
}

struct TrainingZoneDef {
  var maxHRPercent: Double
  var description: String
  var position: Int
}

protocol TrainingStyle {
  static var zones:[TrainingZoneDef] { get }
  static func zone(maxHR: Double, heartRate: Double) -> TrainingZone
}

extension TrainingStyle {
   static func zone(maxHR: Double, heartRate: Double) -> TrainingZone {
    var index = 0
    var zoneMaxHR = maxHR
    var minHR = 0.0
    
     while(heartRate > Self.zones[index].maxHRPercent * maxHR) {
      index += 1
    }
    
     let zone = Self.zones[index]
    
    if(index > 0) {
      minHR = Self.zones[index - 1].maxHRPercent * maxHR
    }
    
     if(index < Self.zones.count - 1) {
      zoneMaxHR = zone.maxHRPercent * maxHR
    }
    
    return TrainingZone(
      maxHRPercent: zone.maxHRPercent,
      description: zone.description,
      position: zone.position,
      minHR: minHR,
      maxHR: zoneMaxHR,
      currentPercentOfHRMax: heartRate / maxHR
    )
  }
}

struct GarminTraining: TrainingStyle {
  static var zones: [TrainingZoneDef] {
      [
        TrainingZoneDef(maxHRPercent: 0.5, description: String(localized: "zone-zero"), position: 0),
        TrainingZoneDef(maxHRPercent: 0.6, description: String(localized: "zone-one"), position: 1),
        TrainingZoneDef(maxHRPercent: 0.7, description: String(localized: "zone-two"), position: 2),
        TrainingZoneDef(maxHRPercent: 0.8, description: String(localized: "zone-three"), position: 3),
        TrainingZoneDef(maxHRPercent: 0.9, description: String(localized: "zone-four"), position: 4),
        TrainingZoneDef(maxHRPercent: Double.infinity, description: String(localized: "zone-five"), position: 5)
      ]
  }
}


