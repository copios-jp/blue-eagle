//
//  File.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/28.
//

import Foundation

struct Endpoints {
    static let publish = "https://blue-eagle-hide.herokuapp.com/publish/"
    static let observe = "https://blue-eagle-hide.herokuapp.com?channel="
}
class Training: NSObject, Encodable, ObservableObject {
    private var _sex: Sex = Sex.male
    var sex: Sex {
        get {
            return self._sex
        }
       set (newVal) {
            self._sex = newVal
            self.calorieCounter.sex = newVal
        }
    }
    private var _weight = 100
    var weight: Int {
        get {
            return _weight
        }
        set (newVal) {
            self._weight = newVal
            self.calorieCounter.weight = newVal
        }
    }
    
    private var _age = 47
    var age: Int {
        get {
            return _age
        }
        
        set (newVal) {
            self._age = newVal
            self.calorieCounter.age = newVal
        }
    }
    private var _broadcasting = false
    var broadcasting: Bool {
        get {
          return _broadcasting
        }
        set (newVal) {
            self._broadcasting = newVal
            if(_broadcasting == true) {
                self.uuid = UUID()
            }
        }
    }

    var uuid = UUID()
    var restingHR: Int = 70
    var endedAt: Date?
    var trainingStyle: TrainingStyle = GarminTraining()
    var samples: [HRSample] = []
    var calorieCounter: CalorieCounter = CalorieCounter()
    var activities: [Activity] = []
    @Published var currentHR: Int = 0
    
    override init() {
        super.init()
        
        self.calorieCounter.configure(age: age, sex: sex, weight: weight)
        NotificationCenter.default.addObserver(self, selector: #selector(heartRateReceived(notification:)), name: NSNotification.Name.HeartRate, object: nil)
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
        // TODO - encode activity
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
    }
    
    public func toJson() -> String {
        guard let json = try? JSONEncoder().encode(self)
        else {
            return "{\"error\": \"Training is unencodable\"}"
        }
        return String(data: json, encoding: .utf8)!
    }
    
    
    private func broadcast() throws {
        Task {
            let url = URL(string: Endpoints.publish + uuid.uuidString)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = self.toJson().data(using: .utf8)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                
                print("bad status error")
                throw DownloadError.statusNotOk
            }
        }
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
            return Int(calorieCounter.calories)
        }
    }
    
    
    var maxHR: Int {
        get {
            return Int(maxHRForAge(age))
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
