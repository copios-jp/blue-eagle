//
//  ContentView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/17.
//
import CoreBluetooth
import SwiftUI


struct ContentView: View {
    
    var bluetoothService : BluetoothService = BluetoothService()
    var profileService : ProfileService = ProfileService()
    @State private var showSettings = false
    @State private var hasAccount = false
    var body: some View {
        if(hasAccount == false) {
            LoginView()
        } else {
        VStack() {
            
                HeartRateView().environmentObject(bluetoothService)
                    .environmentObject(profileService)
            
        }
        .navigationTitle("Blue Eagle")
        .navigationBarItems(trailing: Button(action: {
            showSettings = true
        }) {
            Image(systemName: "pencil")
        })
        .sheet(isPresented: $showSettings) {
            NavigationView {
                SettingsView()
                    .navigationBarItems(leading: Button("Done") {
                        showSettings = false
                    })
                    .environmentObject(bluetoothService)
                    .environmentObject(profileService)
                    
            }
            
        }
    
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView().environmentObject(BluetoothService())
                .environmentObject(ProfileService())
            
        }
    }
}
