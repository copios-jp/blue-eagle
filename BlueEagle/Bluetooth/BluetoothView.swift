//
//  BluetoothView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/27.
//

import Foundation
import SwiftUI
import CoreBluetooth
/*
 
 NOT IN USE
 
 SEE TRAINING VIEW
 
 
 */
struct BluetoothView: View {
    @StateObject var bluetoothService: BluetoothService = BluetoothService()
    @State var showList: Bool = false
    var body: some View {
            VStack {
                Image(systemName: bluetoothService.receiving ? "heart.fill" : "heart")
                    .padding()
                    .symbolRenderingMode(.palette)
                    .font(.headline)
                    .onTapGesture {
                        showList = true
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




