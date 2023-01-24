//
//  StopwatchView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftUI

struct StopwatchView: View {
  private func getColor(_ state: StopWatchStatus) -> Color {
    switch(state) {
      case .paused:
        return .secondary
      case .running:
        return .blue
      default:
        return .primary
    }
  }
  
  @StateObject private var stopwatch: StopWatch = StopWatch()
  var body: some View {
    HStack {
      Text(String(stopwatch.formattedValue))
        .onTapGesture() {
          stopwatch.status == .running ? stopwatch.pause() : stopwatch.start()
        }
        .onLongPressGesture() {
          stopwatch.stop()
        }
        .foregroundStyle(getColor(stopwatch.status))
    }
    .font(.system(.title).monospacedDigit())
  }
}

struct StopwatchView_Previews: PreviewProvider {
  static var previews: some View {
    StopwatchView()
      .preferredColorScheme(.dark)
  }
}
