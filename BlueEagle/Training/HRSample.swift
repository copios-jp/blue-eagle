//
//  HRSample.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/28.
//

import Foundation

struct HRSample: Codable {
    var rate: Int
    var at: Date = Date()
    
    func toJson() -> String {
        guard let json = try? JSONEncoder().encode(self)
        else {
            return "{\"rate\": \(rate), \"at\": \(at)}"
        }
      return String(data: json, encoding: .utf8)!
    }
 }
