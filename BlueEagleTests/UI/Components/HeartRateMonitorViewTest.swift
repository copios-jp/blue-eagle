//
//  HeartRateMonitorViewTest.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/19.
//

import ViewInspector
@testable import BlueEagle
import XCTest
import SwiftUI

final class HeartRateMonitorViewTest: XCTestCase {
  
  let identifier = UUID()
  let eventBus: EventBusMock = .init()
  
  var model: HeartRateMonitorMock?
  var viewModel: HeartRateMonitorViewModel?
  var sut: HeartRateMonitorView?
  
  override func setUpWithError() throws {
    self.model = .init()
    self.viewModel = .init(self.model!)
    sut = .init(viewModel: self.viewModel!)
  }
  
  override func tearDownWithError() throws {
    sut = nil
    eventBus.reset()
  }
  
  func test_itShowsDisconnectedIconWhenNotConnected() throws {
    model!.state = .disconnected
    let systemName: String = try sut.inspect().hStack().find(ViewType.Image.self).actualImage().name()
    let color: Color = try sut.inspect().hStack().find(ViewType.Image.self).foregroundColor()!
    
    XCTAssertEqual(systemName, HeartRateMonitorViewModel.DeadHeartRateMonitorIcon.systemName)
    XCTAssertEqual(color, HeartRateMonitorViewModel.DeadHeartRateMonitorIcon.foregroundColor )
    
  }
   
  func test_itShowsConnectedIconWhenConnected() throws {
    model!.state = .connected
    let systemName =  try sut.inspect().hStack().find(ViewType.Image.self).actualImage().name()
    let color =  try sut.inspect().hStack().find(ViewType.Image.self).foregroundColor()
    
    XCTAssertEqual(systemName, HeartRateMonitorViewModel.LiveHeartRateMonitorIcon.systemName)
    XCTAssertEqual(color, HeartRateMonitorViewModel.LiveHeartRateMonitorIcon.foregroundColor)
  }

  func test_itDoesNotShowNameWhenNotExtended() throws  {
    XCTAssertThrowsError(try sut.inspect().hStack().find(text: viewModel!.name))
  }
  
  func test_itShowsNameWhenExtended() throws {
    sut = .init(viewModel: self.viewModel!, extended: true)
    XCTAssertNoThrow(try sut.inspect().hStack().find(text: viewModel!.name))
  }
  
  func test_viewModelTogglesConnectivity() throws {
    XCTAssertFalse(model!.wasToggled)
    viewModel!.toggle()
    XCTAssertTrue(model!.wasToggled)
  }
 }
