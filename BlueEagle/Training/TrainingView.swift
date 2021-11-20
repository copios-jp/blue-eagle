//
//  HeartRateView.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/01.
//
struct Activity {
    var weight: Int = 80
    var reps:Int = 10
    var startAt: Date?
    
    var endAt: Date?
}
import SwiftUI
import CoreBluetooth
struct TrainingView: View {
    @StateObject private var training: Training = Training()
    @StateObject private var bluetooth: BluetoothService = BluetoothService()
    
    @State private var showQRCode: Bool = false
    @State private var showList: Bool = false
    @State private var editActivity: Bool = false
    @State private var activity :Activity = Activity()
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
                Image(systemName: training.broadcasting ? "person.wave.2.fill" : "person.wave.2")
                    .padding()
                    .onTapGesture {
                        training.broadcasting.toggle()
                        showQRCode = training.broadcasting
                    }
            }
            
            HStack {
                Text("Bench Press - Standard")
                Text("\(activity.weight) kg")
                Text("\(activity.reps)")
                if(activity.endAt == nil) {
                    Button(action: {
                        if(activity.startAt != nil) {
                            activity.endAt = Date()
                        } else {
                            activity.startAt = Date()
                        }
                    }) {
                        Text("\(activity.startAt != nil ? "finish" : "start")")
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
            VStack {
                Text("devices")
                    .font(.headline)
                    .padding()
                List {
                    ForEach(Array(bluetooth.devices), id: \.identifier) { device in
                        HStack {
                            Text("\(device.name!)")
                            Spacer()
                            switch(device.state) {
                            case .connected:
                                Image(systemName: bluetooth.receiving ? "heart.fill" : "heart")
                                    .symbolRenderingMode(.palette)
                                    .font(.headline)
                                    .foregroundStyle(bluetooth.pulse ? .red : .white)
                            case .connecting:
                                ProgressView()
                            default:
                                EmptyView()
                            }
                            
                        }
                        .onTapGesture {
                            bluetooth.connect(device)
                        }
                    }
                }
                Button("done") {
                    bluetooth.stopScan()
                    showList = false
                }.padding()
                Spacer()
            }
        }
        .sheet(isPresented: $showQRCode) {
            VStack {
                Spacer()
                Image(uiImage: UIImage(data: createObserverQRCode(text: Endpoints.observe)!)!)
                    .resizable()
                    .frame(width: 200, height: 200)
                Spacer()
                Button("done") {
                    showQRCode = false
                }
            }
        }
        .sheet(isPresented: $editActivity) {
            VStack {
                Text("activity")
                    .font(.headline)
                    .padding()
                
                Form {
                    Text("Bench Press - Standard")
                    Section(header: Text("weight")) {
                        Stepper(value: $activity.weight, in: 5...500, step: 5) {
                            Text("\(activity.weight) kg")
                        }
                    }
                    Section(header: Text("repetitions")) {
                        Stepper(value: $activity.reps, in: 1...50, step: 1) {
                            Text("\(activity.reps)")
                        }
                    }
                    
            }
                    Spacer()
                    
                    Button("done") {
                        editActivity = false
                    }
                }
        }
    }
}

struct TrainingView_Previews: PreviewProvider {
    static var previews: some View {
        TrainingView()
            .preferredColorScheme(.dark)
    }
}
