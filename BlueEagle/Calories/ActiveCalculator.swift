//
//  BasalCalculator.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/12/06.
//

import Foundation
// Mifflin-St Jeor
// https://www.calculator.net/bmr-calculator.html

class ActiveCalculator {
    static private var intercept: Double {
        get {
            switch(sex) {
            case .male:
                return  -55.0969
            case .female:
                return -20.4022
            case .undeclared:
                return -37.74955
            }
        }
    }
    
    static private var sex: Sex {
        get {
            return Sex(rawValue: Preferences.standard.sex) ?? .undeclared
        }
    }
    
    static var weightCoef:  Double {
        get {
            
            switch(sex) {
            case .male:
                return 0.1988
            case .female:
                return 0.1263
            case .undeclared:
                return  0.16255
            }
        }
    }
    
    static private var rateCoef: Double {
        get {
            switch(sex) {
            case .male:
                return 0.6309
            case .female:
                return 0.4472
            case .undeclared:
                return 0.53905
            }
        }
    }
    
    static private var ageCoef: Double {
        
        get {
            switch(sex) {
            case .male:
                return 0.2017
            case .female:
                return 0.074
            case .undeclared:
                return 0.13785
            }
        }
    }
    
    static func calories(_ heartRate: Int) -> Double {
        @Preference(\.age) var age
        @Preference(\.weight) var weight
        @Preference(\.height) var height
       
        let r = Double(heartRate)
        let a = Double(age)
        let w = Double(weight)
        
        
        return (intercept + rateCoef * r + weightCoef * w + ageCoef * a) / JEWEL_TO_KCAL
        
    }
}


