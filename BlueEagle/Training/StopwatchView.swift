//
//  StopwatchView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftUI

struct StopwatchView: View {
    @StateObject private var stopwatch: StopWatch = StopWatch()
    var body: some View {
        HStack {
            Text(String(stopwatch.formattedValue))
            Image(systemName: stopwatch.status == .stopped ? "stopwatch" : "stopwatch.fill")
                .onTapGesture() {
                    stopwatch.status == .running ? stopwatch.pause() : stopwatch.start()
                }
            
                .onLongPressGesture() {
                    stopwatch.stop()
                }
                .foregroundStyle(stopwatch.status == .paused ? .secondary : .primary)
            
        }
        .font(.system(.largeTitle).monospacedDigit())
    }
}

struct StopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        StopwatchView()
            .preferredColorScheme(.dark)
    }
}
