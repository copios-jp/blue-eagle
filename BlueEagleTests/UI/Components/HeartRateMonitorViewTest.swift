//
//  HeartRateMonitorViewTest.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/19.
//

import SwiftUI
import ViewInspector
import XCTest

@testable import BlueEagle

@MainActor

final class HeartRateMonitorViewTest: XCTestCase {
  let identifier = UUID()
  let Image = ViewType.Image.self
    
  func makeView(extended: Bool = false) throws -> InspectableView<ViewType.ClassifiedView> {
    let model = HeartRateMonitor(name: name, identifier: identifier)
    let viewModel = HeartRateMonitorViewModel(model)
    return try HeartRateMonitorView(viewModel: viewModel, extended: extended).inspect()
  }
 
  func usesIcon(image: InspectableView<ViewType.Image>, name: String, color: Color) throws {
    let systemName: String = try image.actualImage().name()
    let foregroundColor: Color = try image.foregroundColor()!

    XCTAssertEqual(systemName, name)
    XCTAssertEqual(foregroundColor, color)
  }
    
  func test_itShowsDisconnectedIconWhenNotConnected() throws {
    let view = try makeView()
    let image = try view.find(Image)
    
    try usesIcon(image: image, name: "heart.slash", color: .secondary)
  }

  func test_itShowsConnectedIconWhenConnected() throws {
    let view = try makeView()
      
    EventBus.trigger(.HeartRateMonitorConnected, ["identifier": identifier])
    waitForNotification(.HeartRateMonitorConnected)
      
    let image = try view.find(Image)
      
    try usesIcon(image: image, name: "heart.fill", color: .primary)
  }

  func test_itDoesNotShowNameWhenNotExtended() throws {
    let view = try makeView()
    XCTAssertThrowsError(try view.find(text: name))
  }

  func test_itShowsNameWhenExtended() throws {
    let view = try makeView(extended: true)
    XCTAssertNoThrow(try view.find(text: name))
  }
}
