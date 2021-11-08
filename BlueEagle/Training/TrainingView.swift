//
//  HeartRateView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//

import SwiftUI

struct TrainingView: View {
    @StateObject private var training: Training = Training()
    @State private var showQRCode: Bool = false
    
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
                        showQRCode = training.broadcasting
                    }
            }
            TrainingZoneView()
                .environmentObject(training)
            TrainingStatsView()
                .environmentObject(training)
        }.sheet(isPresented: $showQRCode) {
            VStack {
                Image(uiImage: UIImage(data: createObserverQRCode(text: Endpoints.observe)!)!)
                    .resizable()
                    .frame(width: 200, height: 200)
            Button("done") {
                showQRCode = false
            }
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
