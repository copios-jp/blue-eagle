//
//  HeartRateView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//

import SwiftUI

struct HeartRateView: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    @EnvironmentObject var profileService: ProfileService
    private let gradient = AngularGradient(
        gradient: Gradient(colors: [.black, .blue, .yellow, .green, .orange, .red]),
        center: .center,
        startAngle: .degrees(-90),
        endAngle: .degrees(270))
    var body: some View {
        VStack {
            ZStack {
                
                Circle()
                    .stroke(lineWidth: 50.0)
                    .opacity(0.3)
                    .foregroundColor(Color.accentColor)
                
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(bluetoothService.heartRate) / (Double(profileService.profile.maxHeartRate) + 70.0))
                    .rotation(Angle(degrees: -90))
                    .stroke(gradient, style: StrokeStyle(lineWidth: 50.0))
                
                Text("\(bluetoothService.heartRate)")
                    .font(.custom("GIGANTIC", size: 120))
                
            }
            Spacer()
        }
        .padding(80)
    }
    
    
}

struct HeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView().environmentObject(BluetoothService())
            .environmentObject(ProfileService())
    }
}
