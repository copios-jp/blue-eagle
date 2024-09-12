//
//  TrainingZoneViewTest.swift
//  BlueEagleUITests
//
//  Created by Randy Morgan on 2024/06/24.
//

import SwiftUI
import ViewInspector
import XCTest
import Foundation
@testable import BlueEagle

final class TrainingZoneViewTest: XCTestCase {
  var sut: TrainingZoneView?
  var viewModel: TrainingZoneView.ViewModel?
  override func setUpWithError() throws {
    WithUser()
    viewModel = .init()
      sut = .init(viewModel: self.viewModel!)
    let userInfo: [String: AnyHashable] = [
      "identifier": UUID(),
      "sample": Int(Double(User.current.maxHeartRate) * 0.9)
    ]

    EventBus.trigger(.HeartRateMonitorValueUpdated, userInfo)
  }

  override func tearDownWithError() throws {
    sut = nil
  }

  func hasTextWithColor(text: String, color: Color) throws {
    let view = try sut.inspect().find(text: text)
    XCTAssertEqual(try view.attributes().foregroundColor(), color)
  }

  func test_itRendersTrainingZoneViewDescription() throws {
    let text = NSLocalizedString(viewModel!.description, comment:"")
    print("TEXT \(text)")
    let color = viewModel!.color
      
    try hasTextWithColor(text: text, color: color)
  }

  func test_itRendersTrainingZoneViewPercentOfMax() throws {
    let text = viewModel!.heartRateLabel
    let color = viewModel!.color

    try hasTextWithColor(text: text, color: color)
  }
}
