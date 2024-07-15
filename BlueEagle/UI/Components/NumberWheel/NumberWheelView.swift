//
//  NumberWheelView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/13.
//

import SwiftUI

struct NumberWheelView: View {
  @Binding var selection: Int

  var range: ClosedRange<Int> = 0...59
  var format: String = "%02d"
  var fontSize: CGFloat = 80

  private var itemSize: CGSize {
      return String(format: format, 99).size(withAttributes: [
      .font: UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
    ])
  }

  var body: some View {
    ScrollView(.vertical) {
      LazyVStack(alignment: .trailing, spacing: 0) {
        ForEach(range, id: \.self) { value in
          Text(String(format: format, value))
            .id(value)
            .accessibilityLabel("Number \(value)")
        }
      }
      .scrollTargetLayout()
    }
    .scrollPosition(id: Binding($selection), anchor: .center)
    .scrollTargetBehavior(.viewAligned)
    .scrollIndicators(.hidden)
    .font(.system(size: fontSize)).monospacedDigit()
    .frame(width: itemSize.width + 1, height: itemSize.height)
  }
}

#Preview {
  NumberWheelView(selection: .constant(0), range: 0...5, format: "%02d")
}
