//
//  SettingsView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//

import SwiftUI

struct ProfileSettingsView: View {
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

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSettingsView().environmentObject(BluetoothService())
            .environmentObject(ProfileService())
    }
}
