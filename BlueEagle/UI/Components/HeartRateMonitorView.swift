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
        .foregroundColor(viewModel.icon.foregroundColor)
    }
    .contentShape(Rectangle())
  }
}

struct HeartRateMonitorView_Preview: PreviewProvider {
  static var viewModel: HeartRateMonitorViewModel = .init(HeartRateMonitor(name: "preview"))
  static var previews: some View {
    VStack {
      HStack {
        HeartRateMonitorView(viewModel: viewModel)
        Spacer()
      }
      List {
        HeartRateMonitorView(viewModel: viewModel, extended: true)
      }
    }
  }
}
