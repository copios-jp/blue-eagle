//
//  StopwatchView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/30.
//

import SwiftUI

struct StopwatchView: View {

  var model: StopwatchView.ViewModel = .init()

  var body: some View {
    HStack {
      Text(String(model.value))
        .onTapGesture {
          model.onTap()
        }
        .onLongPressGesture {
          model.onLongPress()
        }
        .foregroundStyle(model.color)
    }
    .font(.system(.title).monospacedDigit())
  }
}

struct StopwatchView_Previews: PreviewProvider {
  static var model: StopwatchView.ViewModel = .init()
  static var previews: some View {
    StopwatchView(model: model)
      .preferredColorScheme(.dark)
  }
}
