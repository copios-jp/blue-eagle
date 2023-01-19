//
//  BluetoothView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/26.
//

import SwiftUI
import Combine

struct HeartRateMonitorList: View {
  @StateObject var viewModel: ViewModel = .init()
  @State private var show: Bool = false
  
  var body: some View {
    HStack {
      if viewModel.current == nil {
      HeartRateMonitorView()
    } else {
      HeartRateMonitorView(viewModel: viewModel.current!)
    }

    }
      .onTapGesture { self.show = true }
      .sheet(isPresented: $show) { sheetView(viewModel) }
      .padding()
  }
}

private extension HeartRateMonitorList {
  func sheetView(_ viewModel: HeartRateMonitorList.ViewModel) -> some View {
    NavigationView {
      VStack {
        loadedView
      }
      .navigationTitle("devices")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .destructiveAction) {
          
          Button("done") { self.show = false }
        }
      }
    }
    .onAppear(perform: self.viewModel.scan)
  }
 
  var loadingView: some View {
    ProgressView()
  }
  
  var scanButton: some View {
    Button("scan") { viewModel.scan() }
  }
  
  var loadedView: some View {
    VStack {
      List {
        ForEach(viewModel.items, id: \.self) { monitor in
          HeartRateMonitorView(viewModel: monitor, extended: true)
            .onTapGesture { monitor.toggle() }
        }
      }
      if(viewModel.isScanning) {
        loadingView
      } else {
        scanButton
      }
    }
  }
}

// MARK: Preview

struct HeartRateMonitorList_Previews: PreviewProvider {
  static let monitorViewModel: HeartRateMonitorViewModel = .init(HeartRateMonitor(name: "Preview Monitor"))
  static let viewModel: HeartRateMonitorList.ViewModel = .init(items: [monitorViewModel])
  static var previews: some View {
    GeometryReader { geometry in
      VStack {
        HStack {
          HeartRateMonitorList(viewModel: viewModel)
        }
      }
      .frame(height: geometry.size.height * 0.05)
      Spacer()
    }
  }
}
