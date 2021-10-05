//
//  AccountApi.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/04.
//

import Foundation

class AccountApi: ObservableObject {
    @Published var loginFailed: Bool = false
    @Published var registrationFailed: Bool = false
    
    func handleClientError(error: Error) {
        print("Client Error \(error)")
    }
    
    func handleServerError(response: URLResponse) {
        print(response)
    }
    
    func createAccount(email: String, password: String, completion: @escaping (Account) -> ()) {
        registrationFailed = false
        guard let url = URL(string: "https://localhost:3000/register") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.registrationFailed = true
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.registrationFailed = true
                return
            }
            let account = try! JSONDecoder().decode(Account.self, from: data!)
            
            DispatchQueue.main.async {
                completion(account)
            }
            
        }
        .resume()
    }
    
    func login(email: String, password: String, completion: @escaping (Account) -> ()) {
        loginFailed = false
        guard let url = URL(string: "https://localhost:3000/authenticate") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                self.loginFailed = true
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.loginFailed = true
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
