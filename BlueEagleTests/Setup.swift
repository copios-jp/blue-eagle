//
//  Setup.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/20.
//

import SwiftUI
import ViewInspector
import XCTest

@testable import BlueEagle

// https://github.com/nalexn/ViewInspector
extension Inspection: InspectionEmissary {}
extension InspectableSheet: PopupPresenter {}
extension InspectableFullScreenCover: PopupPresenter {}

func WithUser(birthdate: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date())!,  restingHeartRate: Int = 50) {
    User.birthdate = birthdate
    // = Date(timeIntervalSinceNow: -60 * 60 * 24 * 356 * 30)
    User.restingHeartRate = Double(restingHeartRate)
}
