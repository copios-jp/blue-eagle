//
//  ProfileView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/27.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var profileService: ProfileService
    
    var body: some View {
        Form {
            Section(header: Text("Profile")) {
                HStack {
                    Text("Given Name")
                    Spacer(minLength:100)
                    TextField(
                        "",
                        text: $profileService.profile.givenName,
                        onEditingChanged: { changed in
                            if(changed == false) {
                                profileService.store()
                            }
                        }
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Family Name")
                    Spacer(minLength:100)
                    TextField(
                        "",
                        text: $profileService.profile.familyName,
                        onEditingChanged: { changed in
                            if(changed == false) {
                                profileService.store()
                            }
                        }
                    )
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Birthday")
                    Spacer(minLength:100)
                    DatePicker(
                        "",
                        selection: $profileService.profile.dateOfBirth,
                        displayedComponents: .date
                    )
                }
                HStack {
                    Text("Height (cm)")
                    Spacer(minLength:100)
                    Picker("", selection: $profileService.profile.heightCm) {
                        ForEach(100 ..< 300, id: \.self) { num in Text("\(num)").tag(num) }
                    }
                    .onChange(of: profileService.profile.heightCm) { tag in
                        profileService.store()
                    }
                }
                HStack {
                    Text("Weight (kg)")
                    Spacer(minLength:100)
                    Picker("", selection: $profileService.profile.weightKg) {
                        ForEach(20 ..< 600, id: \.self) { num in Text("\(num)").tag(num) }
                    }
                    .onChange(of: profileService.profile.weightKg) { tag in
                        profileService.store()
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView().environmentObject(ProfileService())
    }
}
