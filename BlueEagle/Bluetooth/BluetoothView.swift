//
//  BluetoothView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/26.
//

import SwiftUI

struct BluetoothView: View {
    @StateObject private var bluetooth: BluetoothService = BluetoothService()
    @State private var show: Bool = false
    var body: some View {
        Image(systemName: bluetooth.receiving ? "heart.fill" : "heart")
                    .padding()
                    .onTapGesture {
                        bluetooth.scan(5.0)
                        self.show = true
                    }
                    .foregroundStyle(bluetooth.pulse ? .primary : .secondary)
        .sheet(isPresented: $show) {
            DevicesView(bluetooth: bluetooth, show: $show)
        }
    }
}

struct BluetoothView_Previews: PreviewProvider {
    static var previews: some View {
        BluetoothView()
    }
}
