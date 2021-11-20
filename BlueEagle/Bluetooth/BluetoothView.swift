//
//  BluetoothView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/27.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct BluetoothView: View {
    @StateObject var bluetoothService: BluetoothService = BluetoothService()
    var body: some View {
        Text(String(bluetoothService.devices.count))
        VStack {
            Image(systemName: bluetoothService.receiving ? "heart.fill" : "heart")
                .padding()
                .symbolRenderingMode(.palette)
                .font(.headline)
                .onTapGesture {
                    bluetoothService.enabled.toggle()
                }
                
                .foregroundStyle(bluetoothService.pulse ? .red : .white)
           
        }
    }
}

struct BluetoothView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothView()
    }
}




