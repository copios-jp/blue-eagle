//
//  Profile.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/09/27.
//

import Foundation
import Combine

class ProfileService: ObservableObject {
    
    @Published var profile: Profile = Profile()

    private var KEY = "Profile"

   
    init() {
        load()
        store()
    }
    
    func load() {
      if let json = UserDefaults.standard.object(forKey: KEY) as? Data {
              profile = try! JSONDecoder().decode(Profile.self, from: json)
      }
    }
    
    func store() {
        let json = try! JSONEncoder().encode(profile)
        UserDefaults.standard.set(json, forKey: KEY)
    }
}

struct Profile: Codable, Equatable {
    var givenName: String = ""
    var familyName: String = ""
    var weightKg: Int = 50
    var heightCm: Int = 150
    var dateOfBirth: Date = Date()
    var age: Int {
        get {
          return Calendar.current.dateComponents([.year], from: self.dateOfBirth, to: Date()).year ?? 0
        }
    }   
    var maxHeartRate: Int {
        get {
            return 220 - self.age
        }
    }
}


