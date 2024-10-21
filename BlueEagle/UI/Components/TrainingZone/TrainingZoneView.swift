//
//  TrainingZoneView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftUI

@MainActor internal struct TrainingZoneView: View {

  static let GradientStops: [(Color, Double)] =
    [
      (.gray, 0.0),
      (.blue, 0.25),
      (.green, 0.40),
      (.yellow, 0.55),
      (.orange, 0.70),
      (.red, 0.85),
    ]

  private static let gradient = AngularGradient(
    gradient: Gradient(
      stops: GradientStops.map { stops in
        Gradient.Stop(color: stops.0, location: stops.1)
      }),
    center: .center,
    startAngle: .degrees(-90),
    endAngle: .degrees(270))

  @StateObject var viewModel: ViewModel = .init()

  var lineWidth: CGFloat = 30

  var body: some View {
    ZStack(alignment: .center) {
      Circle()
        .stroke(Self.gradient, style: StrokeStyle(lineWidth: lineWidth))
        .opacity(0.5)

      // TODO: rotation causes the view to expand to maximum height
      // rotationEffect doesn't rotate the gradient, just the trim
      // Investigate Circle transforms
      Circle()
        .trim(from: 0.0, to: CGFloat(viewModel.exertionGradient))
        .rotation(Angle(degrees: -90.0))
        .stroke(Self.gradient, style: StrokeStyle(lineWidth: lineWidth))
        .opacity(0.8)
        .animation(.easeIn, value: viewModel.exertionGradient)

      Circle()
        .fill(viewModel.color)
        .opacity(0.4)
        .padding(lineWidth / 2 - 1)

      VStack {
        Text(viewModel.exertion)
          .font(.system(size: lineWidth))
        Text(LocalizedStringKey(viewModel.description))
          .font(.system(size: lineWidth))
        Text(viewModel.heartRateLabel)
          .font(.system(size: lineWidth))
      }
      .foregroundColor(viewModel.color)
    }
    .padding(lineWidth / 2)
  }
}

#Preview {
  TrainingZoneView()
}
