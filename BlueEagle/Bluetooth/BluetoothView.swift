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
    @State var showList: Bool = false
    var body: some View {
        VStack {
            Image(systemName: bluetoothService.receiving ? "heart.fill" : "heart")
                .padding()
                .font(.system(.largeTitle))
           
        }
    }
}

struct BluetoothView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothView()
    }
}




