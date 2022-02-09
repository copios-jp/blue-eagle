//
//  File.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/28.
//
import Foundation
import SwiftUI

class Training: NSObject, Encodable, ObservableObject {
    let uuid = UUID()
    var restingHR: Int = 70
    var endedAt: Date?
    var trainingStyle: TrainingStyle = GarminTraining()
    var samples: [HRSample] = []
    var calorieCounter: CalorieCounter = CalorieCounter()
    var activities: [Activity] = []
    @Published var qrcode: QRCode?
    @Published var broadcasting: Bool = false
    @Published var activity :Activity = unselected
    @Published var currentHR: Int = 0
    
    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(heartRateReceived(notification:)), name: NSNotification.Name.HeartRate, object: nil)
        qrcode = QRCode(uuid.uuidString)
    }
    
    private var startedAt: Date?
    
    private enum CodingKeys: String, CodingKey {
        case currentHR
        case trainingZoneDescription
        case trainingZone
        case trainingZoneMax
        case trainingZoneMin
        case percentOfMax
        case averageHR
        case calories
        case at
        case activity
        // TODO - encode activity
    }
    
    public func qr() -> URL {
        let url = URL(string: Endpoints.qrcode + uuid.uuidString )!
        print(url)
        return url
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentHR, forKey: .currentHR)
        try container.encode(currentTrainingZone.description, forKey: .trainingZoneDescription)
        try container.encode(currentTrainingZone.position, forKey: .trainingZone)
        try container.encode(currentTrainingZone.minHR, forKey: .trainingZoneMin)
        try container.encode(currentTrainingZone.maxHR, forKey: .trainingZoneMax)
        try container.encode(averageHR, forKey: .averageHR)
        try container.encode(percentOfMax, forKey: .percentOfMax)
        try container.encode(calories, forKey: .calories)
        try container.encode(Date(), forKey: .at)
        try container.encode(activity, forKey: .activity)
    }
    
    public func toJson() -> String {
        guard let json = try? JSONEncoder().encode(self)
        else {
            return "{\"error\": \"Training is unencodable\"}"
        }
        return String(data: json, encoding: .utf8)!
    }
    
    
    private func broadcast() throws {
        let data: Data = self.toJson().data(using: .utf8)!
        let channel: String = uuid.uuidString
        
        API().broadcast(channel: channel, data: data)
    }
    
    @objc func heartRateReceived(notification: Notification) {
        let heartRate = notification.userInfo!["heart_rate"] as! Int
        addSample(sample: HRSample(rate: heartRate, at: Date()))
        self.currentHR = heartRate
        
        if(broadcasting) {
            do {
                try broadcast()
            } catch {
                print(error)
            }
        }
        
    }
    
    
    var duration: DateComponents {
        get {
            guard let from:Date = startedAt else {
                return Calendar.current.dateComponents([.second, .minute, .hour], from: Date(), to: Date())
            }
            
            let to = endedAt ?? Date()
            
            return Calendar.current.dateComponents([.second, .minute, .hour], from: from, to: to)
        }
    }
    
    var averageHR: Int {
        get {
            if(samples.isEmpty) {
                return 0
            }
            return self.samples.reduce(0) { (memo, sample) -> Int in memo + sample.rate } / samples.count
        }
    }
    
    var reserveHR: Int {
        get {
            return maxHR - restingHR
        }
    }
    
    var currentTrainingZone: TrainingZone {
        get {
            trainingStyle.currentZone(training: self)
        }
    }
    
    var averageTrainingZone: TrainingZone {
        get {
            trainingStyle.averageZone(training: self)
        }
    }
    
    var percentOfMax: Double {
        get {
            return Double(currentHR) / Double(maxHR)
        }
    }
    
    var percentOfReserve: Double {
        get {
            Double(currentHR - restingHR) / Double(reserveHR)
            
        }
    }
    
    var calories: Int {
        get{
            guard let minute = duration.minute else {
                return 0
            }
            
            let minutes = duration.hour! * 60 + minute
            return Int(calorieCounter.caloiesPerMinuteAt(averageHR)) * minutes
        }
    }
    
    
    var maxHR: Int {
        get {
            return Int(maxHRForAge(Preferences.standard.age))
        }
    }
    
    func addSample(sample: HRSample) {
        if(samples.isEmpty) {
            self.startedAt = Date()
        }
        self.calorieCounter.add(sample)
        self.samples.append(sample)
    }
}
