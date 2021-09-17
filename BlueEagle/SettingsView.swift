//
//  SettingsView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var bluetoothService: BluetoothService
    @EnvironmentObject var profileService: ProfileService
    
    var body: some View {
        VStack() {
            BluetoothView()
                .environmentObject(bluetoothService)
            ProfileView()
                .environmentObject(profileService)
            Spacer()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView().environmentObject(BluetoothService())
            .environmentObject(ProfileService())
    }
}
