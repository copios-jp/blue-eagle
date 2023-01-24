//
//  TrainingZoneView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftUI


struct TrainingZoneView: View {
  
  let value: Double
  let description: String
  let color: Color
  let gradient: AngularGradient
  
  init(value: Double, description: String, color: Color) {
    self.value = value
    self.description = description
    self.color = color
    self.gradient = TrainingZoneGradientStyle.gradient
  }
  
  var body: some View {
    ZStack(alignment: .center) {
      Circle()
        .stroke(gradient, style: StrokeStyle(lineWidth: 0))
        .background(Circle().fill(color))
        .opacity(0.2)
        .padding()
      Circle()
        .stroke(gradient, style: StrokeStyle(lineWidth: 35.0))
        .opacity(0.5)
      Circle()
        .trim(from: 0.0, to: CGFloat(value))
        .rotation(Angle(degrees: -90))
        .stroke(gradient, style: StrokeStyle(lineWidth: 35.0))
        .animation(.easeIn, value: value)
      Text("training-zone")
        .padding(.top, -60)
      Text(LocalizedStringKey(description))
        .font(.system(size: 45))
        .foregroundColor(color)
      Text("\(value * 100.0, specifier: "%.0f")%")
        .font(.system(size: 35))
        .padding(.top, 110)
        .foregroundColor(color)
    }
  }
}

struct TrainingZoneView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
        TrainingZoneView(value: 0.7, description: "zone-two", color: .orange)
          .preferredColorScheme(.dark)
          .padding(.leading)
          .padding(.trailing)
    }
    .padding()
  }
}
