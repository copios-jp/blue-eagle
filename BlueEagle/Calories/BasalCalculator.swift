//
//  BasalCalculator.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/12/06.
//

import Foundation
// Mifflin-St Jeor
// https://www.calculator.net/bmr-calculator.html

class BasalCalculator {
    static func intercept() -> Double {
        let sex: Sex = Sex(rawValue: Preferences.standard.sex) ?? .undeclared
        
        switch(sex) {
        case .male:
            return 5
        case .female:
            return -161
        case .undeclared:
            return -78
        }
    }
    
    static func calories() -> Double {
        @Preference(\.age) var age
        @Preference(\.weight) var weight
        @Preference(\.height) var height
        
        let a = Double(age)
        let w = Double(weight)
        let h = Double(height)
        
        return (10.0 * w + 6.25 * h - 5.0 * a + BasalCalculator.intercept()) / 24.0 / 60.0
        
    }
}


