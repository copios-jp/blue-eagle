//
//  HeartRateView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//

import SwiftUI

struct HeartRateView: View {
    
    
    
    @StateObject private var trainingMonitor: TrainingMonitor = TrainingMonitor()
    
   
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: trainingMonitor.receiving ? "heart.fill" : "heart")
                    .padding()
                    .font(.system(.largeTitle))
                StopwatchView()
                Image(systemName: "person.badge.plus")
                    .padding()
                    .font(.system(.largeTitle))
            }
            .padding()
            TrainingZoneView()
                .environmentObject(trainingMonitor.training)
                .padding()
            TrainingStatsView()
                .environmentObject(trainingMonitor.training)
        }
    }
}

struct HeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView()
            .preferredColorScheme(.dark)
    }
}
