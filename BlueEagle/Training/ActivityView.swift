//
//  ActivityView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/11/26.
//

import SwiftUI

struct ActivityView: View {
    @StateObject var training: Training
    @State private var show: Bool = false
    var body: some View {
        HStack {
            if(training.activity == unselected) {
                Text("select activity")
                    .font(.title)
            } else {
                VStack {
                Text(training.activity.name)
                    .truncationMode(.tail)
                    .lineLimit(1)
                    Text("\(training.activity.weight) kg x \(training.activity.reps)")

                    Button(action: {
                        training.activity.endAt = Date()
                        training.activities.append(training.activity)
                        training.activity = Activity(name: training.activity.name, weight: training.activity.weight, reps: training.activity.reps )
                        show.toggle()
                    }) {
                        Text("finish")
                            .padding(.top, 2)
                    }
                
                }
                .font(.title2)
            }
            
        }
        .onTapGesture {
            self.show = true
        }
        .sheet(isPresented: $show, onDismiss: {
            if(self.training.activity != unselected) {
                self.training.activity.startAt = Date()
            }}) {
            ExerciseView(training: training, show: $show)
        }
        
    }
}

struct ActivityView_Previews: PreviewProvider {
    @State static var training = Training()
    static var previews: some View {
        ActivityView(training: training)
    }
}
