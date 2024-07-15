//
//  Settings.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/21.
//

import SwiftUI

struct EditSettingsView: View {
  @Binding var show: Bool
  @StateObject var user: User = User.current

  var body: some View {
    NavigationView {
      VStack {
        Form {
          Picker(selection: $user.sex, label: Text("gender")) {
            ForEach(Sex.allCases, id: \.self) { sex in
              Text(LocalizedStringKey(sex.rawValue))
                .tag(sex)
            }
          }

          Picker(selection: $user.weight, label: Text("weight")) {
            ForEach(40...200, id: \.self) { value in
              Text("\(value) kg")
            }
          }

          Picker(selection: user.$height, label: Text("height")) {
            ForEach(120...250, id: \.self) { value in
              Text("\(value) cm")
            }
          }

          Picker(selection: $user.restingHeartRate, label: Text("resting heart rate")) {
            ForEach(40...100, id: \.self) { value in
              Text("\(value) bpm")
            }
          }

          DatePicker(
            "birthdate", selection: $user.birthdate, in: ...Date(), displayedComponents: .date
          )
          .datePickerStyle(.compact)

          
        }

      }
      .navigationTitle("settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("done") {
            self.show.toggle()
          }
        }
      }
    }
  }
}

struct EditSettingsView_Previews: PreviewProvider {
  static var previews: some View {
    GeometryReader { geometry in
      VStack {
        HStack {
          EditSettingsView(show: .constant(true))
        }
      }
    }

  }
}
