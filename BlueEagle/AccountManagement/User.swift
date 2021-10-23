//
//  User.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/03.
//

import Foundation
import HealthKit

enum BiologicalSex: Codable {
    case notSet
    case male
    case female
}
func encodeEmail(email: String) -> String {
    guard let clean = email.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved) else { return "" }
    return clean
}

struct User: Codable {
    var id: Int
    var fullName: String
    var isSuperAdmin: Bool = false
}
 

