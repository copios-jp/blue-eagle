//
//  ProgramableTimer.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/13.
//

import SwiftUI

struct ProgrammableTimerView: View {
  @StateObject var model: ProgrammableTimerView.ViewModel = .init()
  var fontSize: CGFloat = 100

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            // Timer
            HStack(spacing: 0) {
                NumberWheelView(selection: $model.minutes, fontSize: fontSize)
                    .disabled(model.status == .running)
                    .accessibilityLabel("Minutes \($model.minutes)")
                RatioColon(fontSize: fontSize)
                NumberWheelView(selection: $model.seconds, fontSize: fontSize)
                    .disabled(model.status == .running)
                    .accessibilityLabel("Seconds \($model.seconds)")
            }
            // Controls
            HStack(alignment: .center, spacing: 20) {
                Button("", systemImage: "plus.circle", action: model.addTimer)
                    .disabled(model.status == .running || (model.minutes == 0 && model.seconds == 0))
                    .accessibilityLabel("Add interval")
                Button("", systemImage: model.statusImage, action: model.toggle)
                    .accessibilityLabel("Start/Stop")
                Button("", systemImage: "repeat.circle", action: model.incrementRounds)
                    .disabled(!model.isProgrammed)
                    .accessibilityLabel("add round")
                    .overlay {
                        RoundsCountOverlayView(value: $model.rounds, fontSize: 50)
                    }
                Button("", systemImage: "xmark.circle", role: .destructive, action: model.reset)
                    .disabled(!model.isProgrammed)
                    .accessibilityLabel("Reset intervals and rounds")
            }
            .padding(.leading)
            .padding(.trailing)
            .font(.system(size: 50))
        }
        .font(.system(size: fontSize))
    }
}

#Preview {
  ProgrammableTimerView()
}
