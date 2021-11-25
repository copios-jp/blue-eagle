//
//  SettingsView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/26.
//

import SwiftUI

struct SettingsView: View {
    @StateObject var training: Training
    @State private var show: Bool = false
    var body: some View {
        Image(systemName: training.broadcasting ? "person.wave.2.fill" : "person.fill")
                    .padding()
                    .onTapGesture {
                        show.toggle()
                    }
         .sheet(isPresented: $show) {
            EditSettingsView(training: training, show: $show)
        }

    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var training: Training = Training()
    static var previews: some View {
        SettingsView(training: training)
    }
}
