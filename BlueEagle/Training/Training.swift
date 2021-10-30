//
//  File.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/28.
//

import Foundation


class Training :ObservableObject {
    var sex: Sex = Sex.male
    var weight: Int = 100
    var restingHR: Int = 70
    var age: Int = 47
    var endedAt: Date?
    
    var trainingStyle: TrainingStyle = GarminTraining()
    var samples: [HRSample] = []
    private var startedAt: Date?
    
    var duration: DateComponents {
        get {
            guard let from:Date = startedAt else {
                return Calendar.current.dateComponents([.second, .minute, .hour], from: Date(), to: Date())
            }
            
            let to = endedAt ?? Date()
            
            return Calendar.current.dateComponents([.second, .minute, .hour], from: from, to: to)
        }
    }
    
    var averageHR: Int {
        get {
            if(samples.isEmpty) {
                return 0
            }
            return self.samples.reduce(0) { (memo, sample) -> Int in memo + sample.rate } / samples.count
        }
    }
    
    var currentHR: Int {
        get {
            if(samples.isEmpty) {
                return 0
            }
            
            return samples[samples.count - 1].rate
        }
    }
    
    var reserveHR: Int {
        get {
            return maxHR - restingHR
        }
    }
    
    var currentTrainingZone: TrainingZone {
        get {
            trainingStyle.currentZone(training: self)
        }
    }
    
    var averageTrainingZone: TrainingZone {
        get {
            trainingStyle.averageZone(training: self)
        }
    }
    
    var percentOfMax: Double {
        get {
            return Double(currentHR) / Double(maxHR)
        }
    }
    
    var percentOfReserve: Double {
        get {
            Double(currentHR - restingHR) / Double(reserveHR)
            
        }
    }
    
    var calories: Int {
        get{
            if(samples.isEmpty) {
                return 0
            }
            let durationDouble: Double = (endedAt ?? Date()).timeIntervalSince(startedAt ?? Date()) / 60.0
            return Int(maleCalorieBurnPerMinuteAtHR(heartRate: averageHR, weight: weight, age: age) * durationDouble)
        }
    }
    
    
    var maxHR: Int {
        return 220 - age
    }
    
   func addSample(sample: HRSample) {
        if(samples.isEmpty) {
            self.startedAt = Date()
        }
        
        self.samples.append(sample)
    }
}
