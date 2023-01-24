//
//  Setup.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/20.
//

import XCTest
import SwiftUI
import ViewInspector
@testable import BlueEagle

// https://github.com/nalexn/ViewInspector
extension Inspection: InspectionEmissary { }
extension InspectableSheet: PopupPresenter { }
extension InspectableFullScreenCover: PopupPresenter { }
