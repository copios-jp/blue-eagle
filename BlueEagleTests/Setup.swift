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
extension Inspection: @retroactive InspectionEmissary {}
extension InspectableSheet: @retroactive BasePopupPresenter {}
extension InspectableSheet: @retroactive PopupPresenter {}
extension InspectableFullScreenCover: @retroactive BasePopupPresenter {}
extension InspectableFullScreenCover: @retroactive PopupPresenter {}

func WithUser(birthdate: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date())!,  restingHeartRate: Int = 50) {
    User.current.birthdate = birthdate
    User.current.restingHeartRate = restingHeartRate
}
