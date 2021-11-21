//
//  ExerciseView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/21.
//

import SwiftUI
import Foundation
struct Activity: Hashable, Equatable  {
    var name: String
    var weight: Int = 80
    var reps:Int = 10
    var startAt: Date?
    var endAt: Date?
}

let unselected = Activity(name: "select activity")

let activities = [
    Activity(name: NSLocalizedString("squat", comment: "")),
    Activity(name: NSLocalizedString("chest press", comment: "")),
    Activity(name: NSLocalizedString("deadlift", comment: "")),
    Activity(name: NSLocalizedString("overhead press", comment: ""), weight: 40),
    Activity(name: NSLocalizedString("arm curl", comment: ""), weight: 30),
    Activity(name: NSLocalizedString("triceps pushdown", comment: ""), weight: 60),
    Activity(name: NSLocalizedString("cable row", comment: ""), weight: 80),
    Activity(name: NSLocalizedString("lat pulldown", comment: ""), weight: 40),
    Activity(name: NSLocalizedString("crunch", comment: ""), weight: 5),
    
]

struct ExerciseView: View {
    @Binding var activity: Activity
    @Binding var show: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Picker("activity", selection: $activity) {
                        ForEach(activities, id: \.self)  { value in
                            Text(value.name)
                        }
                    }
                    .labelsHidden()
                    .onChange(of: activity) { selection in
                        activity = Activity(name: selection.name, weight: selection.weight, reps: selection.reps)
                    }
                    if(activity != unselected) {
                        Section(header: Text("activity weight")) {
                            Stepper(value: $activity.weight, in: 5...500, step: 5) {
                                Text("\(activity.weight)")
                            }
                        }
                        Section(header: Text("repetitions")) {
                            Stepper(value: $activity.reps, in: 1...50, step: 1) {
                                Text("\(activity.reps)")
                            }
                        }
                        
                    }
                }
            }
            .navigationBarTitle(Text("configure activity"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.show.toggle()
            }) {
                Text("done")
            })
        }
    }
}

struct ExerciseView_Previews: PreviewProvider {
    @State static var activity: Activity = unselected
    @State static var show: Bool = true
    static var previews: some View {
        ExerciseView(activity: $activity, show: $show)
    }
}
