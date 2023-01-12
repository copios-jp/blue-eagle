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

class CalorieCounter {
  init() {}

  var minimumViableHeartRate: Int = 90

  var minimumSampleRatePerMinute: Int = 30

  var maximumMeasurableHeartRate: Int = 150

  private var sex: Sex {
    return Sex(rawValue: Preferences.standard.sex) ?? .undeclared
  }

  private var age: Int {
    return Preferences.standard.age
  }

  private var weight: Int {
    return Preferences.standard.weight
  }

  private var intercept: Double {
    switch sex {
    case .male:
      return -55.0969
    case .female:
      return -20.4022
    case .undeclared:
      return -37.74955
    }
  }

  private var rateCoef: Double {
    switch sex {
    case .male:
      return 0.6309
    case .female:
      return 0.4472
    case .undeclared:
      return 0.53905
    }
  }

  private var weightCoef: Double {
    switch sex {
    case .male:
      return 0.1988
    case .female:
      return 0.1263
    case .undeclared:
      return 0.16255
    }
  }

  private var ageCoef: Double {
    switch sex {
    case .male:
      return 0.2017
    case .female:
      return 0.074
    case .undeclared:
      return 0.13785
    }
  }

  func caloriesPerMinute(_ heartRate: Int) -> Int {
    if heartRate < minimumViableHeartRate {
      return 0
    }

    let limitedHeartRate: Int = min(heartRate, maximumMeasurableHeartRate)

    let JOULES_TO_KCAL = 4.1845
    var consumed: Double = intercept
    consumed += rateCoef * Double(limitedHeartRate)
    consumed += weightCoef * Double(weight)
    consumed += ageCoef * Double(age)

    consumed = consumed / JOULES_TO_KCAL
    return Int(consumed.rounded())
  }

  func calories(_ training: Training) -> Int {
    let samples: [HRSample] = training.samples
    if samples.isEmpty {
      return 0
    }
    var bucketUpperLimit = samples.first!.at.secondsSince1970 + 60
    var count = 1
    var minutes = [Int: Int]()

    for sample in samples {
      let minute = sample.at.secondsSince1970
      if minute < bucketUpperLimit {
        if let current = minutes[bucketUpperLimit] {
          minutes[bucketUpperLimit] = current + (sample.rate - current) / count
          count += 1
        } else {
          minutes[bucketUpperLimit] = sample.rate
          count = 1
        }
      } else {
        if count < minimumSampleRatePerMinute {
          minutes[bucketUpperLimit] = 0
        }

        bucketUpperLimit = minute + 60
        minutes[bucketUpperLimit] = sample.rate
        count = 1
      }
    }

    if minutes.values.count <= 1, count < minimumSampleRatePerMinute {
      return 0
    }

    return minutes.values.reduce(0) { $0 + caloriesPerMinute($1) }
  }
}
