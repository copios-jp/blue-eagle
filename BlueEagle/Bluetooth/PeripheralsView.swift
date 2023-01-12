//
//  DevicesView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/22.
//

import CoreBluetooth
import SwiftUI

struct PeripheralsView: View {
  @EnvironmentObject var model: BluetoothViewModel
  @Binding var show: Bool

  var body: some View {
    NavigationView {
      VStack {
        if model.isScanning {
          ProgressView()
        }
        if model.isScanning == false && model.peripherals.count == 0 {
          Text("no sensors available")
        }
        Form {
          List(Array(model.peripherals), id: \.identifier) { peripheral in
            Button(action: {
              model.toggle(peripheral)
            }, label: {
              PeripheralRow(peripheral: Peripheral(peripheral))
            })
          }
        }
        Button("scan", action: {
          model.scan()
        })
        Spacer()
      }
      .navigationTitle("devices")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("done") {
            // model.stopScan()
            self.show.toggle()
          }
        }
      }
    }
  }
}

struct PeripheralsView_Previews: PreviewProvider {
  @State static var show: Bool = true
  static let model = BluetoothViewModel()
  static var previews: some View {
    PeripheralsView(show: $show).environmentObject(model)
  }
}
