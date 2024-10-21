//
//  ProgramableTimer.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/13.
//

import SwiftUI

struct ProgrammableTimerView: View {
  @EnvironmentObject var model: ProgrammableTimer

  var fontSize: CGFloat = 150

  private var playStopImage: String {
    model.status == .running ? "stop.circle" : "play.circle"
  }
 
  var body: some View {
    VStack(alignment: .center, spacing: 0) {
      HStack(spacing: 0) {
        NumberWheelView(selection: $model.minutes, fontSize: fontSize)
          .disabled(model.status == .running)
          .accessibilityLabel("Minutes \($model.minutes)")
        RatioColon(fontSize: fontSize - 5)
        NumberWheelView(selection: $model.seconds, fontSize: fontSize)
          .disabled(model.status == .running)
          .accessibilityLabel("Seconds \($model.seconds)")
      }

      HStack(alignment: .center, spacing: 10) {
        Button(action: model.addTimer) {
          Image(systemName: "plus.circle")
        }
        .disabled(model.status == .running || (model.minutes == 0 && model.seconds == 0))
        Button(action: model.toggle) {
          Image(systemName: playStopImage)
        }
        Button(action: model.addRound) {
          Image(systemName: "repeat.circle")
        }
        .disabled(!model.isProgrammed)
        .overlay {
          RoundsCountOverlayView(value: $model.roundsRemaining)
        }
        Button(action: model.reset) {
          Image(systemName: "xmark.circle")
        }
        .disabled(!model.isProgrammed || model.status == .running)
      }
      .font(.largeTitle)
      .imageScale(.large)
    }
  }
}

#Preview {
  ProgrammableTimerView()
    .environment(ProgrammableTimer())
}
