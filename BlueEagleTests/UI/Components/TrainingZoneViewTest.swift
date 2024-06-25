//
//  TrainingZoneViewTest.swift
//  BlueEagleUITests
//
//  Created by Randy Morgan on 2024/06/24.
//

import SwiftUI
import ViewInspector
import XCTest

@testable import BlueEagle

final class TrainingZoneViewTest: XCTestCase {
  var sut: TrainingZoneView?
  var eventBus: EventBus = NotificationCenter.default
  var viewModel: TrainingZoneView.ViewModel?
  override func setUpWithError() throws {
    WithUser()
    viewModel = .init(eventBus)
    sut = .init(viewModel: viewModel!)
    let userInfo: [AnyHashable: AnyHashable] = [
      "identifier": UUID(),
      "sample": User.maxHeartRate * 0.9,
    ]

    eventBus.trigger(.HeartRateMonitorValueUpdated, userInfo)
    print(viewModel!.description)
  }

  override func tearDownWithError() throws {
    sut = nil
  }

  func hasTextWithColor(text: String, color: Color) throws {
    let view = try sut.inspect().find(text: text)
    XCTAssertEqual(try view.attributes().foregroundColor(), color)
  }

  func test_itRendersTrainingZoneViewDescription() throws {
    let text = viewModel!.description
    let color = viewModel!.color

    try hasTextWithColor(text: text, color: color)
  }

  func test_itRendersTrainingZoneViewPercentOfMax() throws {
    let text = viewModel!.percentOfMaxLabel
    let color = viewModel!.color

    try hasTextWithColor(text: text, color: color)
  }
}
