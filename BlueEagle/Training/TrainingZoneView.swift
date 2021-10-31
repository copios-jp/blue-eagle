//
//  TrainingZoneView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftUI
private let colors: [Color] = [
    .black, .blue, .green, .yellow, .orange, .red
]
private let stops: [Gradient.Stop] = [
    Gradient.Stop(color: colors[0], location: 0),
    Gradient.Stop(color: colors[1], location: 0.5),
    Gradient.Stop(color: colors[2], location: 0.6),
    Gradient.Stop(color: colors[3], location: 0.75),
    Gradient.Stop(color: colors[4], location: 0.85),
    Gradient.Stop(color: colors[5], location: 0.9)
]
private let gradient = AngularGradient(
    // gradient: Gradient(colors: colors),
    
    gradient: Gradient(stops: stops),
    center: .center,
    startAngle: .degrees(-90),
    endAngle: .degrees(270))
struct TrainingZoneView: View {
    @EnvironmentObject var training: Training
    var body: some View {
        ZStack {
            Circle()
                .stroke(gradient, style: StrokeStyle(lineWidth: 0))
                .background(Circle().fill(colors[training.currentTrainingZone.position]))
                .opacity(0.2)
                .padding()
            Circle()
                .stroke(gradient, style: StrokeStyle(lineWidth: 35.0))
                .opacity(0.5)
            Circle()
                .trim(from: 0.0, to: CGFloat(training.percentOfMax ))
                .rotation(Angle(degrees: -90))
                .stroke(gradient, style: StrokeStyle(lineWidth: 40.0))
            
            VStack {
                Text("training-zone")
                Text("\(training.currentTrainingZone.description)")
                
                    .font(.system(size: 40))
                    .padding(20)
                Text("\(Int(training.percentOfMax * 100.0))%")
                
                    .font(.title)
                
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
