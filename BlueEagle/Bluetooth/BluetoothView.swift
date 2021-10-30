//
//  BluetoothView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/27.
//

import Foundation
import SwiftUI

struct BluetoothView: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    var body: some View {
        VStack {
            if(bluetoothService.peripheral == nil) {
                Button("Scan"){
                    bluetoothService.scan()
                }
            } else {
                if let name = bluetoothService.peripheral.name {
                    Text(String(name))
                } else {
                    Text("No Monitor Detected")
                }
            }
        }
        .padding()
    }
}

struct BluetoothView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothView().environmentObject(BluetoothService())
    }
}




