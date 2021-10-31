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

func maxHRForAge(_ age: Int) -> Double {
    return 211.0 - 0.67 * Double(age)
}

enum Sex: Int {
    case undeclared = 0
    case female = 1
    case male = 2
}

class CalorieCounter {
    var age: Int = 0
    var weight: Int = 0
    var calories = 0.0
    var sex: Sex = Sex.undeclared {
        didSet {
            switch(sex) {
            case .male:
                self.intercept = -55.0969
                self.rateCoef = 0.6309
                self.weightCoef = 0.1988
                self.ageCoef = 0.2017
            case .female:
                self.intercept = -20.4022
                self.rateCoef = 0.4472
                self.weightCoef = 0.1263
                self.ageCoef = 0.074
            case .undeclared:
                self.intercept = -37.74955
                self.rateCoef = 0.53905
                self.weightCoef = 0.16255
                self.ageCoef = 0.13785
            }
        }
    }
    
    private var intercept = -37.74955
    private var rateCoef = 0.53905
    private var weightCoef = 0.16255
    private var ageCoef = 0.13785
    
    init() {}
    
    init(age: Int, weight: Int, sex: Sex) {
        self.configure(age: age, sex: sex, weight: weight)
    }
    
    func configure(age: Int, sex: Sex, weight: Int) {
        self.age = age
        self.weight = weight
        self.sex = sex
    }
    
    func add(_ sample: HRSample) {
        let max = maxHRForAge(age)
        let r = Double(sample.rate)
        let w = Double(weight)
        let a = Double(age)
        
        // Swain et al. correlation
        if((r / max) < 0.64) {
            self.calories += 1.0 / 60.0
        }
        self.calories += (intercept + rateCoef * r + weightCoef * w + ageCoef * a) / JEWEL_TO_KCAL / 60.0
    }
}

let JEWEL_TO_KCAL = 4.184
let HOUR = Double(60.0)

