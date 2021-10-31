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

struct MaleCalories {
    var intercept = -55.0969
    var rate = 0.6309
    var weight = 0.1988
    var age = 0.2017
    
    func at(_ training: Training) -> Double {
        return (intercept + rate * Double(training.currentHR) + weight * Double(training.weight) + age * Double(training.age)) / JEWEL_TO_KCAL / 60.0
    }
}

let JEWEL_TO_KCAL = 4.184
let HOUR = Double(60.0)

func calories(_ training: Training) -> Double {
     
    let intercept = -55.0969
    let rateCoef = 0.6309
    let weightCoef = 0.1988
    let ageCoef = 0.2017
    
    return (intercept + rateCoef * Double(training.currentHR) + weightCoef * Double(training.weight) + ageCoef * Double(training.age)) / JEWEL_TO_KCAL / 60.0

}
func maleCalorieBurnPerMinuteAtHR(heartRate: Int, weight: Int, age: Int) -> Double {
    
    let intercept = -55.0969
    let rateCoef = 0.6309
    let  weightCoef = 0.1988
    let ageCoef = 0.2017
    
    return (intercept + rateCoef * Double(heartRate) + weightCoef * Double(weight) + ageCoef * Double(age)) / JEWEL_TO_KCAL
}


