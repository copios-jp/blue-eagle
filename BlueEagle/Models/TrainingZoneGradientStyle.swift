//
//  TrainingZoneColor.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/24.
//

import Foundation
import SwiftUI


struct TrainingZoneGradientStyle {
  private static var colors: [Color] = [
    .gray,
    .blue,
    .green,
    .yellow,
    .orange,
    .red
  ]
  
  private static var locations: [Double] = [
    0,
    0.5,
    0.6,
    0.75,
    0.85,
    0.95
  ]
  
  static func color(position: Int) -> Color {
    return colors[position]
  }
  
  static func at(position: Int) -> (color: Color, location: Double) {
    return (colors[position], location: locations[position])
  }
  
  
  static var gradient: AngularGradient {
    var stops: [Gradient.Stop] = []
    for i in 0..<GarminTraining.zones.count {
      let position = GarminTraining.zones[i].position
      let (color, location) = TrainingZoneGradientStyle.at(position: position)
      
      stops.append(Gradient.Stop(color: color, location: location))
    }
    
    return AngularGradient(gradient: Gradient(stops: stops), center: .center, startAngle: .degrees(-90), endAngle: .degrees(270))
  }
}
