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

class User: Codable {
    var id: UUID = UUID()
    var familyName: String
    var givenName: String
    var emailAddress: String
    var useHealthKit: Bool = false
    var biologicalSex: BiologicalSex = .notSet
    var dateOfBirthComponents: DateComponents
}

struct Account: Codable {
    var lastLogin: Date
    var sessionId: String
    var user: User
}
