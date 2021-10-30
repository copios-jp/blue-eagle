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
    var minHR: Int?
    var maxHR: Int?
}

protocol TrainingStyle {
    var zones:[TrainingZone] { get }
    func currentZone(training: Training) -> TrainingZone
    func averageZone(training: Training) -> TrainingZone
}

struct GarminTraining: TrainingStyle {
    var zones: [TrainingZone] {
        get {
            [
                TrainingZone(maxHRPercent: 0.5, description: String(localized: "zone-zero")),
                TrainingZone(maxHRPercent: 0.6, description: String(localized: "zone-one")),
                TrainingZone(maxHRPercent: 0.7, description: String(localized: "zone-two")),
                TrainingZone(maxHRPercent: 0.8, description: String(localized: "zone-three")),
                TrainingZone(maxHRPercent: 0.9, description: String(localized: "zone-four")),
                TrainingZone(maxHRPercent: Double.infinity, description: String(localized: "zone-five"))
            ]
        }
    }
    
    func currentZone(training: Training) -> TrainingZone {
        return getZone(training: training, heartRate: training.currentHR)
    }
    
    func averageZone(training: Training) -> TrainingZone {
        return getZone(training: training, heartRate: training.averageHR)
    }
    
    private func getZone(training: Training, heartRate: Int) -> TrainingZone {
        var index = 0
        var maxHR = training.maxHR
        var minHR = 0
        
        while(Double(training.currentHR) > (zones[index].maxHRPercent * Double(training.maxHR))) {
            index += 1
        }
        
        let zone = zones[index]
        
        if(index > 0) {
            minHR = Int(zones[index - 1].maxHRPercent * Double(training.maxHR))
        }
        
        if(index < zones.count - 1) {
            maxHR = Int(zone.maxHRPercent * Double(training.maxHR))
        }
        
        return TrainingZone(
            maxHRPercent: zone.maxHRPercent,
            description: zone.description,
            minHR: minHR,
            maxHR: maxHR
        )
    }
    
}


