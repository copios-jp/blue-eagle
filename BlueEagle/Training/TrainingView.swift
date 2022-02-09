//
//  HeartRateView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//

import SwiftUI
struct TrainingView: View {
    @StateObject private var training: Training = Training()
    @StateObject private var bluetooth: BluetoothService = BluetoothService()
    // Disable until we have a more concrete use case
    // @StateObject private var activities: Activities = Activities()
    @State private var showSettings: Bool = false
    @State private var showList: Bool = false
    @State private var editActivity: Bool = false
    var body: some View {
        GeometryReader { geometry in
        VStack {
            HStack {
                BluetoothView(bluetooth: bluetooth)
                Spacer()
                StopwatchView()
                Spacer()
                SettingsView(training: training)
            }
                .frame(height: geometry.size.height *  0.05  )
            // Disable until we have a more concrete use case
            // ActivityView(training: training)
            //    .frame(height: geometry.size.height *  0.15  )
            Spacer()
            TrainingZoneView(training: training)
                .frame(height: geometry.size.height * 0.5)
                .padding(.leading)
                .padding(.trailing)

            Spacer()
            TrainingStatsView(training: training)
            
                .frame(height: geometry.size.height *  0.30  )
        }
        }
              
    }
}

struct TrainingView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingView()
            .preferredColorScheme(.dark)
    }
}
