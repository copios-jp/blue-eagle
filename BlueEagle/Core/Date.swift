//
//  Date.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/11.
//

import Foundation

extension Date {
  var secondsSince1970: Int {
    Int(timeIntervalSince1970.rounded())
  }
}
