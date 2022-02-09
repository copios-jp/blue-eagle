//
//  Peripheral.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/12/09.
//

import SwiftUI

import CoreBluetooth

private struct StatusTextView: View {
    var text: String
    var body: some View {
        Text(text).fontWeight(.thin).foregroundColor(.primary)
    }
}

struct PeripheralRow: View {
    var peripheral: Peripheral
    var body: some View {
        HStack {
            Text(peripheral.name).font(.body).foregroundColor(.primary)
            Spacer()
            switch(peripheral.state) {
            case .connected:
                StatusTextView(text: "connected")
            case .connecting:
                ProgressView()
            default:
                StatusTextView(text: "not connected")
            }
        }.padding()
    }
}

struct PeripheralRow_Previews: PreviewProvider {
    static var peripheral = Peripheral(name: "Dummy", state: CBPeripheralState.connected)
    static var previews: some View {
        PeripheralRow(peripheral: peripheral)
    }
}
