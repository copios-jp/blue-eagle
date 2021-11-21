//
//  Settings.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/21.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var training: Training
    @Binding var show: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("you")) {
                        Picker(selection: $training.sex, label: Text("gender")) {
                            ForEach(Sex.allCases, id: \.self)  { sex in
                                Text(LocalizedStringKey(sex.rawValue))
                                    .tag(sex)
                            }
                        }
                        Picker(selection: $training.weight, label: Text("weight")) {
                            ForEach(Array(stride(from: 20, to: 200, by: 5)), id: \.self) { value in
                                Text("\(value) kg")
                            }
                        }
                        Picker(selection: $training.age, label: Text("age")) {
                            ForEach(10 ... 120, id: \.self) { value in
                                Text("\(value)")
                            }
                        }
                        
                    }
                    Section(header: Text("data")) {
                        Toggle(isOn: $training.broadcasting) {
                            Text("broadcast")
                        }
                        if(training.broadcasting) {
                            Image(uiImage: UIImage(data: createObserverQRCode(text: Endpoints.observe + training.uuid.uuidString)!)!)
                                .resizable()
                                .frame(width: 250, height: 250)
                        }
                        
                    }
                }
            }
            .navigationBarTitle(Text("settings"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.show.toggle()
            }) {
                Text("done")
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var show = true
    @State static var training = Training()
    
    static var previews: some View {
        SettingsView(training: training, show: self.$show )
    }
}
