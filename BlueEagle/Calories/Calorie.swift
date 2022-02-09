//
//  TrainingZone.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/24.
//
/*
 
 Keytel LR, Goedecke JH, Noakes TD, Hiiloskorpi H, Laukkanen R, van der Merwe L, Lambert EV. Prediction of energy expenditure from heart rate monitoring during submaximal exercise. J Sports Sci. 2005 Mar;23(3):289-97.
 
 Swain DP, Abernathy KS, Smith CS, Lee SJ, Bunn SA. Target heart rates for the development of cardiorespiratory fitness. Med Sci Sports Exerc. January 1994. 26(1): 112-116.
 
 Tanaka, H., Monhan, K.D., Seals, D.G., Age-predicted maximal heart rate revisited. Am Coll Cardiol 2001; 37:153-156.
 
 Nes, B.M., Janszky, I., Wisløff, U., Støylen, A. and Karlsen, T. (2013), Maximal heart rate in a population. Scand J Med Sci Sports, 23: 697-704. https://doi.org/10.1111/j.1600-0838.2012.01445.x
 
 */


import Foundation
import SwiftUI

func maxHRForAge(_ age: Int) -> Double {
    return 211.0 - 0.67 * Double(age)
}

class CalorieCounter {
    @Preference(\.age) var age
    @Preference(\.weight) var weight
    @Preference(\.height) var height
    
    var sex: Sex {
        get {
            return Sex(rawValue: Preferences.standard.sex) ?? .undeclared
        }
    }
    
    var calories = 0.0
    
    private var intercept = -37.74955
    private var rateCoef = 0.53905
    private var weightCoef = 0.16255
    private var ageCoef = 0.13785
    private var heightCoef = 3.9485
    
    init() {
    }
    
    func caloiesPerMinuteAt(_ heartRate: Int) -> Double {
        let r = Double(heartRate)
        let max = maxHRForAge(age)
        if((r / max) < 0.60) {
            return BasalCalculator.calories()
        }
        
        return ActiveCalculator.calories(heartRate)
    }
    
    func add(_ sample: HRSample) {
        let max = maxHRForAge(age)
        let r  = Double(sample.rate)
        if(r / max > 0.60) {
            self.calories += caloiesPerMinuteAt(sample.rate) / 60.0
        }
    }
}

let JEWEL_TO_KCAL = 4.184
let HOUR = Double(60.0)

