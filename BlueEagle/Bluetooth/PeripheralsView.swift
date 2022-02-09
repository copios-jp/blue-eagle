//
//  DevicesView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/22.
//

import SwiftUI
import CoreBluetooth

struct PeripheralsView: View {
    @ObservedObject var bluetooth: BluetoothService
    @Binding var show: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                if(bluetooth.isScanning) {
                    ProgressView()
                }
                if(bluetooth.isScanning == false && bluetooth.peripherals.count == 0) {
                    Text("no sensors available")
                }
                Form {
                    List(Array(bluetooth.peripherals), id: \.identifier) { peripheral in
                        Button(action: {
                            bluetooth.connect(peripheral)
                        }, label: {
                            PeripheralRow(peripheral: Peripheral(peripheral))
                        })
                    }
                }
                Button("scan", action: {
                    bluetooth.scan(5.0)
                })
                Spacer()
            }
            .navigationTitle("devices")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction ) {
                    Button("done") {
                        bluetooth.stopScan()
                        self.show.toggle()
                    }
                }
            }
            
        }
    }
}

struct PeripheralsView_Previews: PreviewProvider {
    @State static var bluetooth: BluetoothService = BluetoothService()
    @State static var show: Bool = true
    static var previews: some View {
        PeripheralsView(bluetooth: bluetooth, show: $show)
    }
}
