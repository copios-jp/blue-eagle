//
//  TrainingStatsView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftUI

struct TrainingStatsView: View {
    @StateObject var training: Training
    var body: some View {
        VStack {
            Text("\(training.currentHR)")
                .font(.system(size: 35))
                .foregroundColor(colors[training.currentTrainingZone.position])
            Text("\(training.currentTrainingZone.minHR!) - \(training.currentTrainingZone.maxHR!)")
                .padding(.bottom)
            Text("average-hr: \(training.averageHR)")
            Text("calories-burnt: \(training.calories)")
            
        }
        
    }
}

struct TrainingStatsView_Previews: PreviewProvider {
    @StateObject static var training = Training()
    static var previews: some View {
        TrainingStatsView(training: training)
            .preferredColorScheme(.dark)
    }
}
