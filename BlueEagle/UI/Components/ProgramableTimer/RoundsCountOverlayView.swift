//
//  RoundsCountOverlayView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/16.
//

import SwiftUI

struct RoundsCountOverlayView: View {
    @Binding var value: Double
    var fontSize: CGFloat
      @State var foreground: Color = .red
      @State var background: Color = .white
      
      private let size = 16.0
    private var x: CGFloat {
        return fontSize
    }
    private var y: CGFloat {
        fontSize
    }
      
      var body: some View {
        ZStack {
          Capsule()
                .fill(.secondary)
                .frame(width: size * 2, height: size * 1.2, alignment: .topTrailing)
            .position(x: x, y: y)
          if hasTwoOrLessDigits() {
           text()
                  .foregroundColor(.primary)
              .font(Font.caption)
              .position(x: x, y: y)
            } else  {
            Text("99+")
              .foregroundColor(foreground)
              .font(Font.caption)
              .frame(width: size * widthMultplier(), height: size, alignment: .center)
              .position(x: x, y: y)
          }
        }
        .opacity(value == 0 ? 0 : 1)
      }
    func text() -> Text {
        guard value != Double.infinity else { return Text("\(value)")}
       return Text("\(Int(value))")
    }
            func hasTwoOrLessDigits() -> Bool {
          return value < 100 || value == Double.infinity
      }
      
      func widthMultplier() -> Double {
        if value < 10 {
          // one digit
          return 1.5
        } else if value < 100 {
          // two digits
          return 1.5
        } else {
            // TODO guard against this in our model - and live with it until there is actually a need to support
    // huge numbers
          return 2.0
        }
      }
    }
   

#Preview {
    Button("", systemImage: "repeat.circle", action: {})
      .accessibilityLabel("add round")
      .overlay {
          RoundsCountOverlayView(value: .constant(Double.infinity), fontSize: 80)
      }
      .font(.system(size: 80))
}
