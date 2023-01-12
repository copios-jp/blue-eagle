//
//  BluetoothView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/26.
//

import SwiftUI

struct BluetoothView: View {
  @StateObject var model: BluetoothViewModel = .init()
  @State private var show: Bool = false
  var body: some View {
    Image(systemName: model.receiving ? "heart.fill" : "heart")
      .padding()
      .onTapGesture {
        model.scan()
        self.show = true
      }
      .foregroundStyle(model.pulse ? .primary : .secondary)
      .sheet(isPresented: $show) {
        PeripheralsView(show: $show).environmentObject(model)
      }
  }
}

struct BluetoothView_Previews: PreviewProvider {
  static var previews: some View {
    BluetoothView()
  }
}
