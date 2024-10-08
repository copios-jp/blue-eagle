//
//  TrainingZoneView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftData
import SwiftUI

private let gradient = AngularGradient(
  gradient: Gradient(
    stops: GradientStops.map { stops in
      Gradient.Stop(color: stops.0, location: stops.1)
    }),
  center: .center,
  startAngle: .degrees(-90),
  endAngle: .degrees(270))

struct TrainingZoneView: View {
  @StateObject var viewModel: ViewModel = .init()
    
  var strokeWidth: CGFloat = 30
    
  var body: some View {
    ZStack(alignment: .center) {
      Circle()
        .stroke(gradient, style: StrokeStyle(lineWidth: strokeWidth))
        .opacity(0.5)

      Circle()
        .trim(from: 0.0, to: CGFloat(viewModel.exertionGradient))
        .rotation(Angle(degrees: -90))
        .stroke(gradient, style: StrokeStyle(lineWidth: strokeWidth))
        .opacity(0.8)
        .animation(.easeIn, value: viewModel.exertionGradient)
        
      Circle()
        .fill(viewModel.color)
        .opacity(0.4)
        .padding(strokeWidth / 2 - 1)
      
      VStack {
        Text(viewModel.exertion)
          .font(.system(size: 50))
        Text(LocalizedStringKey(viewModel.description))
          .font(.system(size: 40))
        Text(viewModel.heartRateLabel)
          .font(.system(size: 35))
      }
      .foregroundColor(viewModel.color)
    }
    .padding(strokeWidth / 2)
  }
}

struct TrainingZoneView_Previews: PreviewProvider {
  static var viewModel = TrainingZoneView.ViewModel()
  static var previews: some View {
    HStack {
      TrainingZoneView(viewModel: viewModel)
        .preferredColorScheme(.dark)
    }
  }
}
