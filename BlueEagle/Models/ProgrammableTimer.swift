//
//  ProgramableTimerViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/13.
//

import AVFoundation
import Foundation

@Observable
class ProgrammableTimer: ObservableObject, TrainingTimer.Delegate {

  var isProgrammed: Bool {
    return timers.first(where: { $0.direction == .decrementing }) != nil
  }
  var minutes: Int = 0
  var roundsRemaining: Double = Double.infinity
  var seconds: Int = 0
  var status: TrainingTimer.Status {
    currentTimer?.status ?? .stopped
  }

  func start() {
    guard currentTimer?.status != .running else { return }

    // inject an incrementing timer if there are no programmed timers
    if timers.isEmpty {
      addTimer()
    }

    guard let timer = nextTimer() else { return }
    timer.start()
  }

  func stop() {
    guard let timer = currentTimer else { return }

    timer.delegate = nil
    timer.stop()

    if isProgrammed == false {
      timers = []
    }

    extractMinutesAndSeconds(0)

    roundsRemaining = rounds
    index = -1
  }

  func toggle() {
    self.status == .running ? stop() : start()
  }

  func reset() {
    stop()
    timers = []
    rounds = Double.infinity
    roundsRemaining = rounds
  }

  func addRound() {
    rounds = rounds == Double.infinity ? 1 : rounds + 1
    roundsRemaining = rounds
  }

  func addTimer() {
    guard value != 0 || timers.isEmpty else { return }

    timers.append(TrainingTimer(duration: value))
    extractMinutesAndSeconds(0)
  }

  // MARK: Training Timer Delegate

  internal func onTimerStart(_ event: TrainingTimer.Event) {
    extractMinutesAndSeconds(event.value)
  }

  internal func onTimerTick(_ event: TrainingTimer.Event) {
    extractMinutesAndSeconds(event.value)

    if isProgrammed && event.value == 0 {
      alarm.play()
    }
  }

  internal func onTimerStop(_ event: TrainingTimer.Event) {
    extractMinutesAndSeconds(event.value)

    guard isProgrammed, let timer = nextTimer() else { return }

    if index == 0 {
      decrementRounds()
    }

    outOfRounds ? stop() : timer.start()
  }

  // MARK: Private

  private var alarm: AVAudioPlayer = AudioService.load("alarm")
  private var currentTimer: TrainingTimer? {
    guard index >= 0 && index < timers.count else { return nil }
    return timers[index]
  }
  private var index: Int = -1
  private var rounds: Double = Double.infinity
  private var timers: [TrainingTimer] = []
  private var value: TimeInterval {
    Double(seconds + minutes * 60)
  }

  private func extractMinutesAndSeconds(_ value: TimeInterval) {
    self.minutes = Int(value) / 60
    self.seconds = Int(value) % 60
  }

  private func nextTimer() -> TrainingTimer? {
    guard !timers.isEmpty else { return nil }

    index = (index + 1) % timers.count

    let timer = timers[index]
    timer.delegate = self

    return timer
  }

  private var outOfRounds: Bool {
    return roundsRemaining == 0
  }

  private func decrementRounds() {
    guard roundsRemaining != Double.infinity else { return }
    guard index == 0 else { return }

    roundsRemaining = max(0, roundsRemaining - 1)
  }
}
