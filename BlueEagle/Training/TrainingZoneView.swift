//
//  TrainingZoneView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftUI
private let gradient = AngularGradient(
    gradient: Gradient(colors: [.black, .blue, .yellow, .green, .orange, .red]),
    center: .center,
    startAngle: .degrees(-90),
    endAngle: .degrees(270))
struct TrainingZoneView: View {
    @EnvironmentObject var training: Training
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 25.0)
                .opacity(0.3)
                .foregroundColor(Color.accentColor)
            Circle()
                .trim(from: 0.0, to: CGFloat(training.percentOfMax ))
                .rotation(Angle(degrees: -90))
                .stroke(gradient, style: StrokeStyle(lineWidth: 25.0))
            VStack {
                Text("training-zone")
                Text("\(training.currentTrainingZone.description)")
                    .font(.largeTitle)
                    .padding()
                Text("\(Int(training.percentOfMax * 100.0))%")
                    .font(.largeTitle)
            }
        }
        
    }
}

struct TrainingZoneView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingZoneView()
            .environmentObject(Training())
            .preferredColorScheme(.dark)
    }
}
