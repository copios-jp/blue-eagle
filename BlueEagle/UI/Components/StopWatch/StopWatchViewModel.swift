//
//  StopWatchViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/11.
//

import Foundation
import SwiftUI


extension StopwatchView {
  class ViewModel: ObservableObject {
    private var timer: TrainingTimer = .init()
      private var formatter: TimerFormatter = .init()
    init() {}
    
    var value: String {
        self.formatter.format(timer.value)
    }

    private func getColor(_ state: TrainingTimer.TimerStatus) -> Color {
      switch state {
      case .paused:
        return .secondary
      case .running:
        return .blue
      default:
        return .primary
      }
    }

    var color: Color {
      switch timer.status {
      case .paused:
        return .secondary
      case .running:
        return .blue
      default:
        return .primary
      }
    }

    var status: TrainingTimer.TimerStatus {
      return timer.status
    }

    func onTap() {
      switch timer.status {
      case .running:
        timer.pause()
      case .paused:
        timer.resume()
      default:
        timer.start()
      }
    }

    func onLongPress() {
      timer.stop()
    }
  }
}
