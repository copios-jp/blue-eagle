//
//  ProgramableTimerViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/13.
//

import AVFoundation
import Foundation
import Observation

extension ProgrammableTimerView {
  enum ProgrammableTimerStatus {
    case running
    case stopped
  }
    
  @Observable class ViewModel: TimerEventDelegate, ObservableObject {

    private var timers: [TrainingTimer] = []
    private var repeatCount: Double = Double.infinity
    private var index: Int = -1
      
    var status: ProgrammableTimerStatus = .stopped
    var seconds: Int = 0
    var minutes: Int = 0
    var rounds: Double = Double.infinity

    var isProgrammed: Bool {
      return self.timers.first(where: { $0.direction == .decrementing }) !== nil
    }
      
    var statusImage: String {
      status == .running ? "stop.circle" : "play.circle"
    }

    var currentTimer: TrainingTimer? {
      if (0..<self.timers.count).contains(self.index) {
        return self.timers[self.index]
      }

      return nil
    }

    private var value: TimeInterval {
      Double(seconds + minutes * 60)
    }
      
    func incrementRounds() {
      self.rounds = rounds == Double.infinity ? 1 : rounds + 1
    }
      
    func addTimer() {
      guard value > 0 else { return }
        
      let timer = TrainingTimer(duration: value)
      timer.delegate = self
        
      self.timers.append(timer)

      self.minutes = 0
      self.seconds = 0
    }

    func onChange(_ event: TimerEvent) {
      self.minutes = Int(event.value / 60)
      self.seconds = Int(event.value) % 60

      if event.status == .expired {

        self.index = self.index >= self.timers.count - 1 ? 0 : self.index + 1
        if index == 0 {
          self.rounds = rounds == Double.infinity ? rounds : rounds - 1
        }

        let timer = self.timers[self.index]
        timer.status = .stopped
        AudioService.play("alarm")

        if self.rounds > 0 {
          timer.start()
        } else {
          stop()
        }
      }
    }

    func reset() {
      self.stop()
      self.rounds = Double.infinity
      self.timers = []

    }

    func toggle() {
      self.status == .running ? stop() : start()
    }

    private func start() {
      guard self.currentTimer?.status != .running else { return }
        
      self.index = 0
        
      if self.timers.isEmpty {
        let timer = TrainingTimer()
        timer.delegate = self
        self.timers.append(timer)
      }

      currentTimer!.start()
      self.status = .running
    }

    private func stop() {
      guard let timer = self.currentTimer else { return }

      timer.stop()

      if timer.direction == .incrementing {
        self.timers.remove(at: self.index)
      }
      self.minutes = 0
      self.seconds = 0

      self.index = -1
      self.status = .stopped
    }
  }
}
