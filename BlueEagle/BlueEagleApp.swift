//
//  BlueEagleApp.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/17.
//

import SwiftUI

@main
struct BlueEagleApp: App {
  let bluetooth: BluetoothService = .init()

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
