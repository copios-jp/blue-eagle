//
//  HeartRateMonitor.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/17.
//

import SwiftUI

struct HeartRateMonitorView: View {
  @StateObject var viewModel: HeartRateMonitorViewModel = .init(HeartRateMonitor(name: "None"))
  @State var extended: Bool = false
  
  var body: some View {
    HStack {
      if extended {
        Text(viewModel.name).font(.body)
        Spacer()
      }
      Image(systemName: viewModel.icon.systemName)
        .foregroundStyle(viewModel.icon.foregroundStyle)
        .padding()
    }
  }
}

struct HeartRateMonitorView_Preview: PreviewProvider {
  static var monitor: HeartRateMonitorViewModel = .init(HeartRateMonitor(name: "preview"))
  static var previews: some View {
    VStack {
      HStack {
        HeartRateMonitorView(viewModel: monitor)
        Spacer()
      }
      List {
        HeartRateMonitorView(viewModel: monitor, extended: true)
      }
    }
  }
}
