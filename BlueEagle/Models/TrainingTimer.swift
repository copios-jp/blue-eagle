//
//  StopWatch.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/10.
//

import Foundation
import Observation

struct TimerEvent {
  var value: TimeInterval = 0
  var status: TrainingTimer.TimerStatus = .stopped
}

protocol TimerEventDelegate: AnyObject {
  func onChange(_: TimerEvent)
}

final class TimerFormatter {
     private lazy var formatter: DateComponentsFormatter = {
      let formatter = DateComponentsFormatter()
      formatter.allowedUnits = [.hour, .minute, .second]
      formatter.zeroFormattingBehavior = .pad
      formatter.unitsStyle = .positional
      return formatter
    }()

    func format(_ value: TimeInterval = 0) -> String {
       if value >= 3600 {
        self.formatter.allowedUnits.insert(.hour)
      } else {
        self.formatter.allowedUnits.remove(.hour)
      }
      return self.formatter.string(from: value)  ?? "00:00"
    }
}

@Observable class TrainingTimer {
  enum TimerStatus {
    case stopped
    case running
    case paused
    case expired  // Expose expired status for declarative alarm handling on countdown expiration.
  }

  var status: TimerStatus = .stopped {
    didSet { self.broadcast() }
  }

  var value: TimeInterval = 0 {
    didSet { self.broadcast() }
  }

  weak var delegate: TimerEventDelegate?

  enum TimerDirection {
    case incrementing
    case decrementing
  }

  var direction: TimerDirection = .incrementing
  private var initialDuration: TimeInterval = 0

  private var timer: Timer?
  private let interval: TimeInterval = 1.0

  init(duration: TimeInterval = 0) {
    self.initialDuration = max(0, duration)
    self.value = self.initialDuration
    self.direction = self.initialDuration > 0 ? .decrementing : .incrementing
  }

  // MARK: - Timer Controls

  func start() {
    guard self.status == .stopped || self.status == .expired else { return }

    self.value = self.initialDuration
    self.startTimer()
    self.status = .running
  }

  func pause() {
    guard self.status == .running else { return }

    self.killTimer()
    self.status = .paused
  }

  func stop() {
    guard self.status == .running || self.status == .paused else { return }

    self.killTimer()
    self.status = .stopped
  }

  func resume() {
    guard self.status == .paused else { return }

    startTimer()
    self.status = .running
  }

  // MARK: - Timer Logic

  private func startTimer() {
    if self.timer != nil {
      self.killTimer()
    }

    self.timer = Timer.scheduledTimer(withTimeInterval: self.interval, repeats: true) {
      [weak self] _ in
      self?.tick()
    }
  }

  private func increment() {
    self.value += self.interval
  }

  private func decrement() {
    self.value -= self.interval

    if self.value < 0 {
      self.killTimer()
      self.status = .expired
    }
  }

  @objc private func tick() {
    switch status {
    case .running:
      self.direction == .incrementing ? self.increment() : self.decrement()
    case .paused, .stopped, .expired:
      break
    }
  }

  private func killTimer() {
    self.timer?.invalidate()
    self.timer = nil
  }

  private func broadcast() {
    self.delegate?.onChange(TimerEvent(value: self.value, status: self.status))

  }
  deinit {
    self.killTimer()
  }
}
