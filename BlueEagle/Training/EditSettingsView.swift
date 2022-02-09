//
//  Settings.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/21.
//

import SwiftUI

struct EditSettingsView: View {
    @StateObject var training: Training
    @Binding var show: Bool
    @Preference(\.age) var age
    @Preference(\.weight) var weight
    @Preference(\.height) var height
    @Preference(\.sex) var sex
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Form {
                        Section(header: Text("you")) {
                            Picker(selection: $sex, label: Text("gender")) {
                                ForEach(Sex.allCases, id: \.self)  { sex in
                                    Text(LocalizedStringKey(sex.rawValue))
                                        .tag(sex.rawValue)
                                }
                            }
                            Picker(selection: $weight, label: Text("weight")) {
                                ForEach(Array(stride(from: 20, to: 200, by: 1)), id: \.self) { value in
                                    Text("\(value) kg")
                                }
                            }
                            Picker(selection: $age, label: Text("age")) {
                                ForEach(10 ... 120, id: \.self) { value in
                                    Text("\(value)")
                                }
                            }
                            Picker(selection: $height, label: Text("height")) {
                                ForEach(120 ... 250, id: \.self) { value in
                                    Text("\(value)")
                                }
                            }
                        }
                        /*
                        Section(header: Text("data")) {
                            Toggle(isOn: $training.broadcasting) {
                                Text("broadcast")
                            }
                            
                            if(training.broadcasting && training.qrcode?.image != nil) {
                                VStack {
                                Text("live access URL")
                                HStack{
                                    Spacer()
                                Image(uiImage: training.qrcode!.image!)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxWidth: 200, maxHeight: 200)
                                Spacer()
                                }
                                }.padding()
                            }
                        }
                        */
                    }
                }
                                Spacer()
            }
            .navigationTitle("settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction ) {
                    Button("done") {
                        self.show.toggle()
                    }
                }
            }
            
        }
        
    }
}

struct EditSettingsView_Previews: PreviewProvider {
    @State static var show = true
    @State static var training = Training()
    
    static var previews: some View {
        EditSettingsView(training: training, show: self.$show )
    }
}
