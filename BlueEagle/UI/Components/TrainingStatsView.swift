//
//  TrainingStatsView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftUI

struct TrainingStatsView: View {
  
  let currentHR: Double
  let minHR: Double
  let maxHR: Double
  let averageHR: Double
  let color: Color
  
  var body: some View {
    VStack {
      Text("\(currentHR, specifier: "%.0f")")
        .font(.system(size: 35))
        .foregroundColor(color)
      Text("\(minHR, specifier: "%.0f") - \(maxHR, specifier: "%.0f")")
        .padding(.bottom)
      Text("average-hr: \(averageHR, specifier: "%.0f")")
    }
  }
}

struct TrainingStatsView_Previews: PreviewProvider {
  
  static var previews: some View {
    TrainingStatsView(currentHR: 0, minHR: 0, maxHR: 1, averageHR: 0, color: .orange)
      .preferredColorScheme(.dark)
  }
}
