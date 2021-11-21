//
//  HeartRateView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//

import SwiftUI
import CoreBluetooth
struct TrainingView: View {
    @StateObject private var training: Training = Training()
    @StateObject private var bluetooth: BluetoothService = BluetoothService()
    
    @State private var showSettings: Bool = false
    @State private var showList: Bool = false
    @State private var editActivity: Bool = false
    @State private var activity :Activity = unselected
    @State private var baseActivity: Activity = unselected
    var body: some View {
        VStack {
            HStack {
                Image(systemName: bluetooth.receiving ? "heart.fill" : "heart")
                    .padding()
                    .symbolRenderingMode(.palette)
                    .font(.headline)
                    .onTapGesture {
                        bluetooth.scan(false)
                        showList = true
                    }
                    .foregroundStyle(bluetooth.pulse ? .red : .white)
                Spacer()
                StopwatchView()
                Spacer()
                Image(systemName:  "chart.xyaxis.line")
                    .foregroundColor(.gray)
                Image(systemName: training.broadcasting ? "person.wave.2.fill" : "person.wave.2")
                    .padding()
                    .onTapGesture {
                        showSettings.toggle()
                    }
            }
            
            HStack {
                if(activity == unselected) {
                    Text("select activity")
                } else {
                    Text(activity.name)
                    Text("\(activity.weight) kg")
                    Text("\(activity.reps)")
                    if(activity.endAt == nil) {
                        // todo -
                        // need to add activity to training current.activity
                        // when started so we can broadcast out the current activity
                        // to remote client
                        Button(action: {
                            if(activity.startAt != nil) {
                                activity.endAt = Date()
                                training.activities.append(Activity(name: activity.name, weight: activity.weight, reps: activity.reps))
                                activity = unselected
                                print(training.activities.count)
                            } else {
                                activity.startAt = Date()
                            }
                        }) {
                            Text("\(activity.startAt != nil ? "finish" : "start")")
                        }
                    }
                }
            }.onTapGesture {
                editActivity = true
            }.padding(.top)
            
            TrainingZoneView()
                .environmentObject(training)
            TrainingStatsView()
                .environmentObject(training)
        }
        .sheet(isPresented: $showList) {
            DevicesView(bluetooth: bluetooth, show: $showList)
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(training: training, show: $showSettings)
        }
        .sheet(isPresented: $editActivity) {
            ExerciseView(activity: $activity, show: $editActivity)
        }
    }
}

struct TrainingView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingView()
            .preferredColorScheme(.dark)
    }
}
