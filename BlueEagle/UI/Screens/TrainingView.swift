//
//  HeartRateView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//

import SwiftUI

struct TrainingView: View {
    var body: some View {
        
            VStack(spacing: 0) {
                HStack {
                    HeartRateMonitorListView()
                    Spacer()
                    SettingsView()
                }
                .imageScale(.medium)
                
                ViewThatFits {
                    HStack(alignment: .center) {
                        TrainingZoneView(strokeWidth: 15)
                        ProgrammableTimerView(fontSize: 160)
                    }
                    
                    VStack(alignment: .center, spacing: 0) {
                        TrainingZoneView(strokeWidth: 40)
                        ProgrammableTimerView(fontSize: 120)
                        Spacer()
                    }
                }
            .environment(ProgrammableTimer())
        }
            .padding()
    }
}

struct TrainingView_Previews: PreviewProvider {
  static var previews: some View {
    TrainingView()
      .preferredColorScheme(.dark)
      .environment(ProgrammableTimer())
  }
}
