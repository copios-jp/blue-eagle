//
//  BluetoothView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/26.
//

import Combine
import SwiftUI

struct HeartRateMonitorListView: View {
  @StateObject var viewModel: ViewModel = .init()
  @State var show: Bool = false

  let inspection = Inspection<Self>()

  var body: some View {
    HStack {
     if viewModel.current == nil {
         HeartRateMonitorView(viewModel: .init(HeartRateMonitor(name: "None")))
      } else {
        HeartRateMonitorView(viewModel: viewModel.current!)
     }
    }
    .onTapGesture { self.show = true }
    .fullScreenCover2(isPresented: $show) {
      NavigationView {
        VStack {
          List {
            ForEach(viewModel.items, id: \.self) { monitorViewModel in
              HeartRateMonitorView(viewModel: monitorViewModel, extended: true)
                .onTapGesture { monitorViewModel.toggle() }
            }
          }
          if viewModel.isScanning {
            loadingView
          } else {
            scanButton
          }
        }
        .navigationTitle("devices")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .destructiveAction) {
            Button("done") { self.show = false }
          }
        }

      }
    }
    .padding()
    .onReceive(inspection.notice) { self.inspection.visit(self, $0) }
    .onAppear(perform: viewModel.scan)
  }
}

extension HeartRateMonitorListView {
  fileprivate var loadingView: some View {
    ProgressView()
  }

  fileprivate var scanButton: some View {
    Button("scan") { viewModel.scan() }
  }
}

// MARK: Preview

struct HeartRateMonitorList_Previews: PreviewProvider {
  static let monitorViewModel: HeartRateMonitorViewModel = .init(
    HeartRateMonitor(name: "Preview Monitor"))
  static let viewModel: HeartRateMonitorListView.ViewModel = .init(items: [monitorViewModel])
  static var previews: some View {
    GeometryReader { geometry in
      VStack {
        HStack {
          HeartRateMonitorListView(viewModel: viewModel)
        }
      }
      .frame(height: geometry.size.height * 0.05)
      Spacer()
    }
  }
}
