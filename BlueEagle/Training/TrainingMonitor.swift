//
//  TrainingZone.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/24.
//
/*
 Calculator Formulas
 Formulas for Determination of Calorie Burn if VO2max is Unknown
 Male: ((-55.0969 + (0.6309 x HR) + (0.1988 x W) + (0.2017 x A))/4.184) x 60 x T
 Female: ((-20.4022 + (0.4472 x HR) - (0.1263 x W) + (0.074 x A))/4.184) x 60 x T
 where
 
 HR = Heart rate (in beats/minute)
 
 W = Weight (in kilograms)
 
 A = Age (in years)
 
 T = Exercise duration time (in hours)
 
 Formulas for Determination of Calorie Burn if VO2max is Known
 Male: ((-95.7735 + (0.634 x HR) + (0.404 x VO2max) + (0.394 x W) + (0.271 x A))/4.184) x 60 x T
 Female: ((-59.3954 + (0.45 x HR) + (0.380 x VO2max) + (0.103 x W) + (0.274 x A))/4.184) x 60 x T
 where
 
 HR = Heart rate (in beats/minute)
 
 VO2max = Maximal oxygen consumption (in mL•kg-1•min-1)
 
 W = Weight (in kilograms)
 
 A = Age (in years)
 
 T = Exercise duration time (in hours)
 
 Formula for Determination of Maximum Heart Rate Based on Age
 Maximum Heart Rate (beats/minute) = 208 - (0.7 x Age)
 Formula for Exercise Intensity Conversion from %MHR to %VO2max
 %VO2max = 1.5472 x %MHR - 57.53
 where
 
 %MHR = Percentage of maximum heart rate
 
 %VO2max = Percentage of VO2max
 
 */
import Foundation

extension NSNotification.Name {
    static let HeartRate = NSNotification.Name(rawValue: "heart_rate")
}

enum MaleCalorieCoefficients: Double {
    case intercept = -55.0969
    case rate = 0.6309
    case  weight = 0.1988
    case age = 0.2017
}

enum FemaleCalorieCoefficients: Double {
    case intercept = -20.4022
    case rate = 0.4472
    case weight = 0.1263
    case age = 0.074
}


enum GenericCalorieCoefficients: Double {
    case intercept = -37.74955
    case rate = 0.53905
    case weight = 0.16255
    case age = 0.13785
}

enum Sex: Int {
    case undeclared = 0
    case female = 1
    case male = 2
}

let JEWEL_TO_KCAL = 4.184
let HOUR = Double(60.0)


func maleCalorieBurnPerMinuteAtHR(heartRate: Int, weight: Int, age: Int) -> Double {
    
    let intercept = -55.0969
    let rateCoef = 0.6309
    let  weightCoef = 0.1988
    let ageCoef = 0.2017
    
    return (intercept + rateCoef * Double(heartRate) + weightCoef * Double(weight) + ageCoef * Double(age)) / JEWEL_TO_KCAL
}



class TrainingMonitor: NSObject, ObservableObject {
    var bluetoothService: BluetoothService = BluetoothService()
    var deadstickTimer: Timer?
    @Published var training: Training = Training()
    
    @Published var receiving: Bool = false
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(heartRateReceived(notification:)), name: NSNotification.Name.HeartRate, object: nil)
        
    }
    
    @objc func heartRateReceived(notification: Notification) {
        let heartRate = notification.userInfo!["heart_rate"] as! Int
        let sample = HRSample(rate: heartRate)
        training.addSample(sample: sample)
        checkStick()
        
        
    }
    
    func checkStick() {
        self.deadstickTimer?.invalidate()
        let samples = training.samples
        if(samples.count > 10) {
            var i = samples.count - 5
            let hr = samples[samples.count - 1].rate
            var all = true
            while(all && i < samples.count) {
              
                all = samples[i].rate == hr
                i += 1
            }
            self.receiving = !all
            
            if(self.receiving) {
                
                deadstickTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { [weak self] (timer) in
                    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                        
                        DispatchQueue.main.async {
                            self?.receiving = false
                            
                        }
                    }
                })
            }
        } else {
            self.receiving = true
        }
    }
    
}
