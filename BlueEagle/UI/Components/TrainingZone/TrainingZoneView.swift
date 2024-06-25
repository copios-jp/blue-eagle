//
//  TrainingZoneView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftUI

struct TrainingZoneView: View {
  @State var viewModel: ViewModel = .init()

  var body: some View {
    ZStack(alignment: .center) {
      Circle()
        .stroke(viewModel.gradient, style: StrokeStyle(lineWidth: 0))
        .background(
          Circle().fill(viewModel.color)
        )
        .opacity(0.2)
        .padding()
      Circle()
        .stroke(viewModel.gradient, style: StrokeStyle(lineWidth: 35.0))
        .opacity(0.5)
      Circle()
        .trim(from: 0.0, to: CGFloat(viewModel.percentOfMax))
        .rotation(Angle(degrees: -90))
        .stroke(viewModel.gradient, style: StrokeStyle(lineWidth: 35.0))
        .animation(.easeIn, value: viewModel.percentOfMax)
        .accessibilityIdentifier("TrainingZoneCircle")
      Text("training-zone")
        .padding(.top, -60)
      Text(LocalizedStringKey(viewModel.description))
        .font(.system(size: 45))
        .foregroundColor(viewModel.color)
        .accessibilityIdentifier("TrainingZoneDesription")
      Text(viewModel.percentOfMaxLabel)
        .font(.system(size: 35))
        .padding(.top, 110)
        .foregroundColor(viewModel.color)
        .accessibilityLabel("PercentOfMaxHeartRate")
    }
  }
}

struct TrainingZoneView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      TrainingZoneView()
        .preferredColorScheme(.dark)
        .padding(.leading)
        .padding(.trailing)
    }
    .padding()
  }
}
