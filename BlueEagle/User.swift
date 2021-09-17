//
//  User.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/03.
//

import Foundation
import HealthKit

enum BiologicalSex: Codable {
    case notSet
    case male
    case female
}

class User: Codable {
    var id: UUID = UUID()
    var familyName: String
    var givenName: String
    var emailAddress: String
    var useHealthKit: Bool = false
    var biologicalSex: BiologicalSex = .notSet
    var dateOfBirthComponents: DateComponents
}

struct Account: Codable {
    var lastLogin: Date
    var sessionId: String
    var user: User
}

class Api {
    func handleClientError(error: Error) {
      print("Client Error \(error)")
    }
    
    func handleServerError(response: URLResponse) {
      print(response)
    }
    func createAccount(user: User) {
        
    }
    func login(email: String, password: String, completion: @escaping (Account) -> ()) {
        guard let url = URL(string: "https://localhost:3000/authenticate") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                self.handleClientError(error: error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.handleServerError(response: response!)
                return
            }
                
            
            let account = try! JSONDecoder().decode(Account.self, from: data!)
            DispatchQueue.main.async {
                completion(account)
            }
            
        }
        .resume()
    }
}
