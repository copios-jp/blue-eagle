//
//  KarvonenTrainingZones.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/06/25.
//

import Foundation

private let DEAD = 0.0
private let ZoneOne = 0.5
private let ZoneTwo = 0.6
private let ZoneThree = 0.7
private let ZoneFour = 0.8
private let ZoneFive = 0.9
private let Maximum = Double.infinity

struct TrainingZone: Equatable {

  // minimum heart rate in zone as calculated by the kernel
  var lowerBound: Double = -Double.infinity

  // maximum heart rate in zone as calculated by the kernel
  var upperBound: Double = Double.infinity

  // description of the zone
  var description: String = "Unknown Zone"

  func range(_ kernel: (_ bound: Double) -> Double) -> Range<Double> {
    return kernel(lowerBound)..<kernel(upperBound)
  }
}

let TrainingZones: [TrainingZone] = [
  TrainingZone(
    upperBound: ZoneOne,
    description: "zone-zero"
  ),
  TrainingZone(
    lowerBound: ZoneOne,
    upperBound: ZoneTwo,
    description: "zone-one"
  ),
  TrainingZone(
    lowerBound: ZoneTwo,
    upperBound: ZoneThree,
    description: "zone-two"
  ),
  TrainingZone(
    lowerBound: ZoneThree,
    upperBound: ZoneFour,
    description: "zone-three"
  ),
  TrainingZone(
    lowerBound: ZoneFour,
    upperBound: ZoneFive,
    description: "zone-four"
  ),
  TrainingZone(
    lowerBound: ZoneFive,
    description: "zone-five"
  ),
]
