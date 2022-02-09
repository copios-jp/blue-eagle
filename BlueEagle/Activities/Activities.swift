//
//  Activities.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/12/10.
//

import Foundation
import SwiftUI

struct ActivityGroupType: Codable {
    var label: String
    var id: Int32
}

struct ActivityGroup {
var label: String
}
struct ActivityType: Codable {
    var id: Int32
    var groups: [Int32]
    var label: String
    var weight: Int32
    var repetitions: Int32
}

struct ActivitiesData: Codable {
    var groups: [ActivityGroupType]
    var activities: [ActivityType]
}

class Activities: ObservableObject {
    
    // @Published var list
    @Published var data: ActivitiesData?
    @Published var groups: [ActivityGroupType] = []
    @Published var activites: [ActivityType] = []
    
    init() {
        self.load()
    }
    
    func load() {
        API().activities() { data in
            self.data = try! JSONDecoder().decode(ActivitiesData.self, from: data)
            print(self.data?.groups)
        }
    }
}
