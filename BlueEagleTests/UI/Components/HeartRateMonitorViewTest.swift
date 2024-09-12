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

final class HeartRateMonitorViewTest: XCTestCase {

  let identifier = UUID()
  let eventBus: EventBusMock = .init()

  var model: HeartRateMonitor?
  var viewModel: HeartRateMonitorViewModel?
  var sut: HeartRateMonitorView?

  override func setUpWithError() throws {
    self.model = .init(identifier: identifier)
    self.viewModel = .init(self.model!)
    sut = .init(viewModel: self.viewModel!)
  }

  override func tearDownWithError() throws {
    sut = nil
    eventBus.reset()
  }

  func test_itShowsDisconnectedIconWhenNotConnected() throws {
    let systemName: String = try sut.inspect().hStack().find(ViewType.Image.self).actualImage()
      .name()
    let color: Color = try sut.inspect().hStack().find(ViewType.Image.self).foregroundColor()!

    XCTAssertEqual(systemName, HeartRateMonitorViewModel.DeadHeartRateMonitorIcon.systemName)
    XCTAssertEqual(color, HeartRateMonitorViewModel.DeadHeartRateMonitorIcon.foregroundColor)

  }

  func test_itShowsConnectedIconWhenConnected() throws {
    eventBus.trigger(.HeartRateMonitorConnected, ["identifier": identifier])
    let systemName = try sut.inspect().hStack().find(ViewType.Image.self).actualImage().name()
    let color = try sut.inspect().hStack().find(ViewType.Image.self).foregroundColor()

    XCTAssertEqual(systemName, HeartRateMonitorViewModel.LiveHeartRateMonitorIcon.systemName)
    XCTAssertEqual(color, HeartRateMonitorViewModel.LiveHeartRateMonitorIcon.foregroundColor)
  }

  func test_itDoesNotShowNameWhenNotExtended() throws {
    XCTAssertThrowsError(try sut.inspect().hStack().find(text: viewModel!.name))
  }

  func test_itShowsNameWhenExtended() throws {
    sut = .init(viewModel: self.viewModel!, extended: true)
    XCTAssertNoThrow(try sut.inspect().hStack().find(text: viewModel!.name))
  }
}
