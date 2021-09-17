//
//  GATT.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/24.
//
import CoreBluetooth
import Foundation

struct GATT {
    static let heartRateMeasurement:CBUUID = CBUUID(string: "2A37")
    static let bodySensorLocation: CBUUID = CBUUID(string: "2A38")
    static     let heartRate: CBUUID = CBUUID(string: "0x180D")
    static     let headset:CBUUID = CBUUID(string: "0x1108")
    static     let headsetAudioGateway:CBUUID = CBUUID(string:"0x1112")
    static     let headsetHS: CBUUID = CBUUID(string:"0x1131")
    static     let genericAudio: CBUUID = CBUUID(string:"0x1203")
    static     let bose: CBUUID = CBUUID(string:"0xFEBE")
}


