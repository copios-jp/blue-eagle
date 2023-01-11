//
//  Peripheral.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/12/09.
//

import CoreBluetooth
import Foundation

class Peripheral: NSObject, ObservableObject {
  @objc var peripheral: CBPeripheral?
  var observation: NSKeyValueObservation?
  var identifier: UUID
  @Published var state: CBPeripheralState = .disconnected
  @Published var name: String = ""

  init(name: String, state: CBPeripheralState) {
    self.name = name
    self.state = state
    identifier = UUID()
    super.init()
  }

  init(_ peripheral: CBPeripheral) {
    self.peripheral = peripheral
    state = peripheral.state
    name = peripheral.name!
    identifier = peripheral.identifier
    super.init()

    observation = observe(\.peripheral?.state) { object, _ in
      self.state = object.state
    }
  }

  deinit {
    observation?.invalidate()
  }
}
