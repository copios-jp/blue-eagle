//
//  StopWatch.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import Foundation

enum StopWatchStatus {
    case stopped
    case running
    case paused
}

class StopWatch: ObservableObject {
    
    @Published var status: StopWatchStatus = .stopped
    @Published var value: Int = 0
    private var timer: Timer?
    
    init() {
    }
    
    var formattedValue: String {
        get {
            let minutes :Int = value / 60
            let seconds :Int = value % 60
            
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    func start() {
        if(status == .running) {
            return
        }
        
        if(status == .stopped) {
            self.value = 0
        }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.value += 1
        }
        
        status = .running
    }
    
    func pause() {
        if(status != .running) {
            return
        }
        
        timer?.invalidate()
        status = .paused
    }
    
    func stop() {
        if(status == .stopped) {
            return
        }
        timer?.invalidate()
        status = .stopped
        
    }
}
