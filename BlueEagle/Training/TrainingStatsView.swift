//
//  TrainingStatsView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftUI

struct TrainingStatsView: View {
    @EnvironmentObject var training: Training
    var body: some View {
        VStack {
                Text("\(training.currentHR) bpm")
                .font(.largeTitle)
            Text("\(training.currentTrainingZone.minHR!) - \(training.currentTrainingZone.maxHR!)")

            .padding(.bottom)
            Text("average-hr: \(training.averageHR)")
        Text("calories-burnt: \(training.calories)")

        }
        
    }
}

struct TrainingStatsView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingStatsView()
            .environmentObject(Training())
            .preferredColorScheme(.dark)
    }
}
