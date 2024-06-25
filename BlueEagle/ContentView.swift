//
//  ContentView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/17.
//
import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      TrainingView()
    }
    .preferredColorScheme(.dark)
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      ContentView()
    }
  }
}
