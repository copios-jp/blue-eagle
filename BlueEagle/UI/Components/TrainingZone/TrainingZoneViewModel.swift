//
//  TrainingZoneViewModel.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/06/24.
//

import Foundation
import SwiftUI

extension TrainingZoneView {
  @MainActor internal class ViewModel: ObservableObject {
    private var user: User = User.current

    var color: Color {
      let zoneIndex = TrainingZones.firstIndex(of: user.zone)
      return TrainingZoneView.GradientStops[zoneIndex!].0
    }

    var description: String {
      return user.heartRate > 0 ? user.zone.description : "NO SIGNAL"
    }

    var exertion: String {
      return user.heartRate > 0
        ? user.exertion.formatted(.percent.precision(.fractionLength(0))) : ""
    }

    // Because a linear gradient looks shit when zone-zero eats up
    // half of the guage.
    var exertionGradient: Double {
      let exertion = user.exertion
      let firstZoneEndsAt = TrainingZones[0].upperBound
      let contractionLimit = GradientStops[1].1

      func contract() -> Double { return exertion * firstZoneEndsAt }
      func expand() -> Double {
        return contractionLimit + (exertion - firstZoneEndsAt)
          / (firstZoneEndsAt / (1 - contractionLimit))
      }

      return user.exertion <= TrainingZones[0].upperBound ? contract() : expand()
    }

    var heartRateLabel: String {
      return user.heartRate > 0 ? String(format: "%d bpm", Int(user.heartRate)) : ""
    }
  }
}
