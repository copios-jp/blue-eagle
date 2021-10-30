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
            .frame(width: 100, alignment: .center)
            .font(.largeTitle)
        Image(systemName: stopwatch.status == .stopped ? "stopwatch" : "stopwatch.fill")
            .font(.system(.largeTitle))
            .onTapGesture() {
                print("toggle")
                stopwatch.status == .running ? stopwatch.pause() : stopwatch.start()
            }
            .onLongPressGesture() {
                stopwatch.stop()
            }
        }
        .font(Font.body.monospacedDigit())
    }
}

struct StopwatchView_Previews: PreviewProvider {
    static var previews: some View {
        StopwatchView()
            .preferredColorScheme(.dark)
    }
}
