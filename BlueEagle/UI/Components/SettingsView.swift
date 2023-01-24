//
//  SettingsView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/26.
//

import SwiftUI

struct SettingsView: View {
  @State private var show: Bool = false
  var body: some View {
    Image(systemName:  "person.fill")
      .padding()
      .onTapGesture {
        show.toggle()
      }
      .fullScreenCover2(isPresented: $show) {
        EditSettingsView(show: $show)
      }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    GeometryReader { geometry in
      VStack {
        HStack {
          Spacer()
          SettingsView()
        }
      }
      .frame(height: geometry.size.height * 0.05)
      Spacer()
    }
  }
}
