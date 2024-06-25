//
//  User.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/06/22.
//

import Foundation

final public class User {
  static var birthdate: Date {
      get {
          return Preferences.standard.birthdate
      }
      set {
          Preferences.standard.birthdate = newValue
          
      }
  }

  static var age: Double {
    let intAge = Calendar.current.dateComponents([.year], from: birthdate, to: Date()).year!

    return Double(intAge)
  }

  static var maxHeartRate: Double {
    211.0 - 0.67 * age
  }

  static var reserveHR: Double {
    return maxHeartRate - restingHeartRate
  }

  static var sex: String {
    get {
      return Preferences.standard.sex
    }
    set {
      Preferences.standard.sex = newValue
    }
  }

  static var weight: Double {
    get {
      return Double(Preferences.standard.weight)
    }
    set {
      Preferences.standard.weight = Int(newValue)
    }
  }

  static var height: Double {
    get {
      return Double(Preferences.standard.height)
    }
    set {
      Preferences.standard.weight = Int(newValue)
    }
  }

  static var restingHeartRate: Double {
    get {
      return Double(Preferences.standard.restingHeartRate)
    }
    set {
      Preferences.standard.restingHeartRate = Int(newValue)
    }
  }

  var heartRateMonitor: String? {
    return Preferences.standard.heartRateMonitor
  }

}
