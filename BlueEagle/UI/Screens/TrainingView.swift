//
//  HeartRateView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//

import SwiftUI
struct TrainingView: View {
  @StateObject private var training: Training
  
  init(training: Training = .init()) {
    self._training = .init(wrappedValue: training)
  }
  
  var body: some View {
    GeometryReader { geometry in
      VStack {
        HStack {
          HeartRateMonitorList()
          Spacer()
          StopwatchView()
          Spacer()
          SettingsView()
        }
        .frame(height: geometry.size.height * 0.05)
        Spacer()
        TrainingZoneView(
          value: training.percentOfMax,
          description: training.zone.description,
          color: TrainingZoneGradientStyle.color(position: training.zone.position)
        )
          .frame(height: geometry.size.height * 0.5)
          .padding(.leading)
          .padding(.trailing)
        Spacer()
        TrainingStatsView(
          currentHR: training.currentHR,
          minHR: training.zone.minHR,
          maxHR: training.zone.maxHR,
          averageHR: training.averageHR,
          color: TrainingZoneGradientStyle.color(position: training.zone.position)
        )
          .frame(height: geometry.size.height * 0.30)
      }
    }
  }
}

struct TrainingView_Previews: PreviewProvider {
  static var previews: some View {
    TrainingView()
      .preferredColorScheme(.dark)
      .padding()
  }
}
