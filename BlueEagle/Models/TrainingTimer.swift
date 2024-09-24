//
//  StopWatch.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/10.
//

import Foundation
import SwiftUI

class TrainingTimer: Equatable {
  static func == (lhs: TrainingTimer, rhs: TrainingTimer) -> Bool {
    return lhs === rhs
  }

  enum Direction {
    case incrementing
    case decrementing
  }

  enum Status {
    case running
    case stopped
  }

  enum EventName {
    case start
    case tick
    case stop
  }

  struct Event {
    var name: EventName = .tick
    var value: TimeInterval = 0
    var direction: Direction = .incrementing
    var status: Status
  }

  protocol Delegate: AnyObject {
    func onTimerTick(_ event: Event)
    func onTimerStart(_ event: Event)
    func onTimerStop(_ event: Event)
  }
    
  private var initialDuration: TimeInterval = 0
  private var timer: Timer?
  private var startAt: Date?
  private let tickInterval: TimeInterval = 1.0
   
  private(set) var value: TimeInterval = 0
  private(set) var direction: Direction = .incrementing
  var status: Status {
    timer == nil ? .stopped : .running
  }

  weak var delegate: Delegate?
    
  init(duration: TimeInterval = 0) {
    self.initialDuration = max(0, duration)
    self.value = initialDuration
    self.direction = initialDuration > 0 ? .decrementing : .incrementing
  }

  func start() {
    if timer != nil {
      killTimer()
    }
    startAt = Date()
    value = initialDuration
      
    timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) {
      [weak self] _ in
      self?.tick()
    }

    broadcast(.start)
  }

  func stop() {
    guard timer != nil else { return }

    killTimer()
    broadcast(.stop)
  }

  @objc private func tick() {
    guard timer != nil else { return }
      
    let interval = Double(Date().timeIntervalSince(startAt!)).rounded()
    value = direction == .incrementing ? interval : initialDuration - interval

    guard value > -1 else {
      killTimer()
      broadcast(.stop)
      return
    }

    broadcast()
  }

  private func killTimer() {
    guard timer != nil else { return }
    timer?.invalidate()
    timer = nil
    value = 0
    startAt = nil
  }

  private func broadcast(_ name: EventName = .tick) {
    guard let target = delegate else { return }

    let event = Event(name: name, value: value, direction: direction, status: status)
    switch name {
    case .start:
      target.onTimerStart(event)
    case .tick:
      target.onTimerTick(event)
    case .stop:
      target.onTimerStop(event)
    }
  }

  deinit {
    killTimer()
  }
}
