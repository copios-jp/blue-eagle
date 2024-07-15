//
//  TrainingTimer.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/10.
//
//

import Foundation

enum TimerStatus {
  case stopped
  case running
  case paused
  case expired
}

enum TimerDirection: Int {
  case incrementing = 1
  case decrementing = -1
}

class TrainingTimer: ObservableObject {

  @Published var status: TimerStatus = .stopped
  @Published var value: Int = 0

  private var direction: TimerDirection = .incrementing
  private var duration: Int = 0

  private var timer: Timer?

  private let interval: Double = 1.0

  init(_ duration: Int = 0) {
    self.duration = duration
    self.value = duration
    self.direction = duration > 0 ? .decrementing : .incrementing
  }

  var formattedValue: String {
    let hours: Int = value / 3600
    let minutes: Int = value / 60
    let seconds: Int = value % 60

    var minutesAndSeconds = String(format: "%02d:%02d", minutes, seconds)

    return hours > 0 ? String(format: "%02d:", hours) + minutesAndSeconds : minutesAndSeconds
  }

  func start() {
    if status == .running {
      return
    }

    if [.stopped, .expired].contains(status) {
      self.value = duration
    }

    timer = Timer.scheduledTimer(
      timeInterval: interval, target: self, selector: #selector(update), userInfo: nil,
      repeats: true)

    status = .running
  }

  @objc func update() {
    if self.direction == .decrementing && self.value == 0 {
      timer?.invalidate()
      self.status = .expired

      return
    }

    self.value += 1 * self.direction.rawValue
  }

  func pause() {
    if status != .running {
      return
    }

    timer?.invalidate()
    status = .paused
  }

  func stop() {

    if status == .stopped {
      return
    }

    timer?.invalidate()
    status = .stopped

  }
}
