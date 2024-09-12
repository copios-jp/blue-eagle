//
//  HeartRateMonitorListViewTest.swift
//  BlueEagleTests
//
//  Created by Randy Morgan on 2023/01/20.
//

import SwiftUI
import ViewInspector
import XCTest

@testable import BlueEagle

final class HeartRateMonitorListViewTest: XCTestCase {

  let eventBus: EventBusMock = .init()
  let timeout = 0.2
  var viewModel: HeartRateMonitorListView.ViewModel?

  var sut: HeartRateMonitorListView?
  var monitor1: HeartRateMonitor?
  var monitor2: HeartRateMonitor?

  override func setUpWithError() throws {
    monitor1 = HeartRateMonitor.init(name: "discovered")
    monitor2 = HeartRateMonitor.init(name: "another")

    viewModel = .init(
      items: [
        HeartRateMonitorViewModel.init(monitor1!),
        HeartRateMonitorViewModel.init(monitor2!),
      ])

    sut = .init(viewModel: self.viewModel!)
  }

  override func tearDownWithError() throws {
    eventBus.reset()
  }

  private func listIsVisible(
    _ view: ViewInspector.InspectableView<ViewInspector.ViewType.View<HeartRateMonitorListView>>
  ) throws {
    XCTAssertNoThrow(try view.hStack().fullScreenCover())
  }

  private func listIsNotVisible(
    _ view: ViewInspector.InspectableView<ViewInspector.ViewType.View<HeartRateMonitorListView>>
  ) throws {
    XCTAssertThrowsError(try view.hStack().fullScreenCover())
  }

  private func openList(
    _ view: ViewInspector.InspectableView<ViewInspector.ViewType.View<HeartRateMonitorListView>>
  ) throws {
    try view.find(HeartRateMonitorView.self).callOnTapGesture()
  }

  // NOTE: ViewInspector does not traverse view modifiers like full screen cover so this
  // only works for the top level monitor view. You must explicitly read from fullscreenCover
  //

  private func hasHeartRateMonitorView(
    _ view: ViewInspector.InspectableView<ViewInspector.ViewType.View<HeartRateMonitorListView>>,
    name: String = ""
  ) throws {
    let monitorView = try view.find(HeartRateMonitorView.self).actualView()
    XCTAssertEqual(monitorView.viewModel.name, name)
  }

  private func hasHeartRateMonitorView(
    _ view: ViewInspector.InspectableView<ViewInspector.ViewType.FullScreenCover>, name: String = ""
  ) throws {
    XCTAssertNoThrow(try view.find(HeartRateMonitorView.self, containing: name))
  }

  func test_itShowsADefaultNoneViewWhenNothingIsConnected() throws {
    let exp = sut!.inspection.inspect { view in
      try self.hasHeartRateMonitorView(view, name: "None")
    }

    ViewHosting.host(view: sut)
    wait(for: [exp], timeout: timeout)

  }

  func test_itShowsConnectedMonitor() throws {
    let exp = sut!.inspection.inspect { view in
      try self.hasHeartRateMonitorView(view, name: "None")

      let monitor = self.viewModel!.items[0]
      self.eventBus.trigger(.HeartRateMonitorConnected, ["identifier": monitor.identifier])

      try self.hasHeartRateMonitorView(view, name: monitor.name)
    }

    ViewHosting.host(view: sut)
    wait(for: [exp], timeout: timeout)
  }

  func test_itDoesNotShowTheListByDefault() throws {
    let exp: XCTestExpectation = sut!.inspection.inspect { view in
      try self.listIsNotVisible(view)
    }

    ViewHosting.host(view: sut)
    wait(for: [exp], timeout: timeout)
  }

  func test_itShowsTheListWhenTapped() throws {
    let exp: XCTestExpectation = sut!.inspection.inspect { view in
      try self.openList(view)
      try self.listIsVisible(view)
    }

    ViewHosting.host(view: sut)

    wait(for: [exp], timeout: timeout)
  }

  func test_itShowsExtendedHeartRateMonitorViewsForDiscoveredDevices() throws {
    let exp = sut!.inspection.inspect { view in

      try self.openList(view)
      let list = try view.hStack().fullScreenCover()
      let items = self.viewModel!.items
      for index in 0..<items.count {
        try self.hasHeartRateMonitorView(list, name: items[index].name)
      }
    }

    ViewHosting.host(view: sut)
    wait(for: [exp], timeout: timeout)
  }

  func test_itTogglesHeartRateMonitorConnectionsOnTap() throws {
    let exp = sut!.inspection.inspect { view in

      try self.openList(view)

      let monitor = try view.hStack().fullScreenCover().find(HeartRateMonitorView.self)
      let identifier = try monitor.actualView().viewModel.identifier
      let userInfo = ["identifier": identifier]

      try monitor.callOnTapGesture()

      XCTAssertTrue(self.eventBus.hasCall(.BluetoothRequestConnection, userInfo))

      self.eventBus.trigger(.HeartRateMonitorConnected, userInfo)
      try monitor.callOnTapGesture()

      XCTAssertTrue(self.eventBus.hasCall(.BluetoothRequestDisconnection, userInfo))
    }

    ViewHosting.host(view: sut)
    wait(for: [exp], timeout: timeout)
  }

  func test_itHidesTheListOnDone() throws {
    let exp = sut!.inspection.inspect { view in
      try self.openList(view)
      let done = try view.find(button: "done")
      try done.tap()

      try self.listIsNotVisible(view)
    }

    ViewHosting.host(view: sut)
    wait(for: [exp], timeout: timeout)
  }
}
