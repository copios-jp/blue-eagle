//
//  RoundsCountOverlayView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/16.
//

import SwiftUI

struct RoundsCountOverlayView: View {
  @Binding var value: Double
  @State var foreground: Color = .white
  @State var background: Color = .red

  private var text: String {
    guard value != Double.infinity else { return "∞" }
    return "\(Int(value))"
  }

  func position(_ size: CGSize) -> CGPoint {
    return CGPoint(x: size.width * 0.85, y: size.height * 0.05)
  }

  func scaledFontSize(_ size: CGSize) -> CGFloat {
    return size.width / 4
  }

  func scaledCapsuleSize(_ size: CGSize) -> CGSize {
    return CGSize(width: size.width / 2.7, height: size.height / 2.7)
  }

  var body: some View {
    ZStack {
      GeometryReader { geometry in
        Circle()
          .fill(background)
          .frame(
            width: scaledCapsuleSize(geometry.size).width,
            height: scaledCapsuleSize(geometry.size).height
          )
          .position(position(geometry.size))
        Text(text)
          .foregroundColor(foreground)
          .font(.system(size: scaledFontSize(geometry.size)))
          .position(position(geometry.size))

      }
    }
  }
}

#Preview {
  Button("", systemImage: "repeat.circle", action: {})
    .accessibilityLabel("add round")
    .overlay {
      RoundsCountOverlayView(value: .constant(Double.infinity))
    }
    .font(.system(size: 80))
}
