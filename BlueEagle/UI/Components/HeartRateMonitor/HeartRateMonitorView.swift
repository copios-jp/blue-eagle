//
//  HeartRateMonitor.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/17.
//

import SwiftUI

struct HeartRateMonitorView: View {
  @ObservedObject var viewModel: HeartRateMonitorViewModel = .init(HeartRateMonitor(name: "None"))

  var body: some View {
    HStack {
      Text(viewModel.name).font(.body)
      Spacer()
      Image(systemName: viewModel.systemName)
        .foregroundColor(viewModel.foregroundColor)
    }
  }
}

#Preview {
  HeartRateMonitorView()
}
