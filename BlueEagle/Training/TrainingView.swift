//
//  HeartRateView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//

import SwiftUI

struct TrainingView: View {
    @StateObject private var training: Training = Training()
    
    var body: some View {
        VStack {
            HStack {
                BluetoothView()
                Spacer()
                StopwatchView()
                Spacer()
                Image(systemName: training.broadcasting ? "person.wave.2.fill" : "person.wave.2")
                    .padding()
                    .onTapGesture {
                        training.broadcasting.toggle()
                    }
            }
            TrainingZoneView()
                .environmentObject(training)
            TrainingStatsView()
                .environmentObject(training)
        }
    }
}

struct TrainingView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingView()
            .preferredColorScheme(.dark)
    }
}
