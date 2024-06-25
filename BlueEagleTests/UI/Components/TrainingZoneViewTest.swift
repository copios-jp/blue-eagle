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

  override func setUpWithError() throws {
    sut = .init()
  }

  override func tearDownWithError() throws {
    sut = nil
  }

  func test_itRendersTrainingZoneView() throws {

    let description = try sut.inspect().zStack().text(1)

    XCTAssertEqual(try description.string(), "foo")
  }
  /*
  func test_itShowsZoneName() throws {
    let zone = TrainingZone(id: 1, name: "Zone 1", color: .red, min: 0, max: 100)
    let viewModel = TrainingZoneViewModel(zone: zone)
    let sut = TrainingZoneView(viewModel: viewModel)
    let name = try sut.inspect().text().string()
    XCTAssertEqual(name, "Zone 1")
  }

  func test_itShowsZoneColor() throws {
    let zone = TrainingZone(id: 1, name: "Zone 1", color: .red, min: 0, max: 100)
    let viewModel = TrainingZoneViewModel(zone: zone)
    let sut = TrainingZoneView(viewModel: viewModel)
    let color = try sut.inspect().color()
    XCTAssertEqual(color, .red)
  }
*/
}
