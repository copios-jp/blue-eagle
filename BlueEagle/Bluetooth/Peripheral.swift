//
//  Peripheral.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/12/09.
//

import Foundation
import CoreBluetooth

class Peripheral: NSObject, ObservableObject {
    @objc var peripheral: CBPeripheral?
    var observation: NSKeyValueObservation?
    
    @Published var state: CBPeripheralState = CBPeripheralState.disconnected
    @Published var name: String = ""
   
    init(name: String, state: CBPeripheralState) {
        self.name = name
        self.state = state
        super.init()
    }
    
    init(_ peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.state = peripheral.state
        self.name = peripheral.name!
        super.init()
       
        observation = observe(\.peripheral?.state) { object, change in
            self.state = object.state
        }
    }
    
    deinit {
        observation?.invalidate()
    }
}
