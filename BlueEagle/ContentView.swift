//
//  ContentView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/17.
//
import CoreBluetooth
import SwiftUI


struct ContentView: View {
    @State private var showSettings = false
    var body: some View {
        VStack() {
            TrainingView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}
