//
//  HeartRateView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//

import SwiftUI

struct TrainingView: View {
  var body: some View {
    GeometryReader { geometry in
      VStack {
        HStack {
          HeartRateMonitorListView()
          Spacer()
          // StopwatchView()
          Spacer()
          SettingsView()
        }
        .frame(height: geometry.size.height * 0.05)
        TrainingZoneView()
          .frame(height: geometry.size.height * 0.50)
          .padding()
        ProgrammableTimerView(fontSize: 120)
          // .frame(height: geometry.size.height * 0.50)
      }
    }
  }
}

struct TrainingView_Previews: PreviewProvider {
  static var previews: some View {
    TrainingView()
      .preferredColorScheme(.dark)
  }
}
