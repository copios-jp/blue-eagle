//
//  BlueEagleApp.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/17.
//

import SwiftUI



@main
struct BlueEagleApp: App {
    
    var userController : UserController = UserController()
    var body: some Scene {
        WindowGroup {

            NavigationView {
              ContentView()
                    .environmentObject(userController)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
