//
//  ExerciseView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/21.
//

import SwiftUI
import Foundation
struct Activity: Hashable, Equatable, Encodable  {
    var name: String
    var weight: Int = 80
    var reps:Int = 10
    var startAt: Date?
    var endAt: Date?
}

let unselected = Activity(name: NSLocalizedString("unselected", comment: ""))

let activities = [
    unselected,
    Activity(name: NSLocalizedString("squat", comment: "")),
    Activity(name: NSLocalizedString("chest press", comment: "")),
    Activity(name: NSLocalizedString("deadlift", comment: "")),
    Activity(name: NSLocalizedString("overhead press", comment: ""), weight: 40),
    Activity(name: NSLocalizedString("arm curl", comment: ""), weight: 30),
    Activity(name: NSLocalizedString("triceps pushdown", comment: ""), weight: 60),
    Activity(name: NSLocalizedString("cable row", comment: ""), weight: 80),
    Activity(name: NSLocalizedString("lat pulldown", comment: ""), weight: 40),
    Activity(name: NSLocalizedString("crunch", comment: ""), weight: 5),
    
    Activity(name: NSLocalizedString("half deadlift", comment:""), weight: 60),
    Activity(name: NSLocalizedString("seated cable row", comment:""), weight: 170),
    Activity(name: NSLocalizedString("single leg squat one hand row", comment:""), weight: 40),
    Activity(name: NSLocalizedString("muscle rowing one hand", comment:""), weight: 15)
]


struct ExerciseView: View {
    @StateObject var training: Training
    @State private var selection: Activity = unselected
    
    @Binding var show: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Picker("activity", selection: $training.activity) {
                        ForEach(activities, id: \.self)  { value in
                            Text(value.name)
                                .tag(value)
                        }
                    }
                    .labelsHidden()
                    .onChange(of: selection) { selection in
                        training.activity = Activity(name: selection.name, weight: selection.weight, reps: selection.reps, startAt: Date())
                        
                    }
                    if(training.activity != unselected) {
                        Section(header: Text("activity weight")) {
                            Picker(selection: $training.activity.weight, label: Text("weight")) {
                                ForEach(Array(stride(from: 5, to: 500, by: 5)), id: \.self) { value in
                                    Text("\(value) kg")
                                }
                            }
                        }
                        Section(header: Text("repetitions")) {
                            Picker(selection: $training.activity.reps, label: Text("repetitions")) {
                                ForEach(Array(stride(from: 1, to: 30, by: 1)), id: \.self) { value in
                                    Text("\(value)")
                                }
                            }
                        }
                        
                    }
                }
            }
            .navigationTitle("configure activity")
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

struct ExerciseView_Previews: PreviewProvider {
    @State static var show = true
    @State static var training = Training()
    static var previews: some View {
        ExerciseView(training: training, show: $show)
    }
}
