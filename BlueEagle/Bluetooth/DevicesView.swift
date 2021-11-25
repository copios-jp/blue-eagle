//
//  DevicesView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/22.
//

import SwiftUI

struct DevicesView: View {
    @StateObject var bluetooth: BluetoothService
    @Binding var show: Bool
    @Preference(\.heartRateMonitor) var preferredDevice
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    List {
                        ForEach(Array(bluetooth.devices), id: \.identifier) { device in
                            HStack {
                                Text("\(device.name!)")
                                Spacer()
                                switch(device.state) {
                                case .connected:
                                    Image(systemName: bluetooth.receiving ? "heart.fill" : "heart")
                                        .symbolRenderingMode(.palette)
                                        .font(.headline)
                                        .foregroundStyle(bluetooth.pulse ? .red : .white)
                                case .connecting:
                                    ProgressView()
                                default:
                                    EmptyView()
                                }
                                
                            }
                            .onTapGesture {
                                bluetooth.connect(device)
                            }
                        }
                    }
                }
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

struct DevicesView_Previews: PreviewProvider {
    @State static var bluetooth: BluetoothService = BluetoothService()
    @State static var show: Bool = true
    static var previews: some View {
        DevicesView(bluetooth: bluetooth, show: $show)
    }
}
