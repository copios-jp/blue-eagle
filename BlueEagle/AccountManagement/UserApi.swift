//
//  AccountApi.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/04.
//

import Foundation

class UserApi: ObservableObject {
    @Published var loginFailed: Bool = false
    @Published var registrationFailed: Bool = false
    
    func handleClientError(error: Error) {
        print("Client Error \(error)")
    }
    
    func handleServerError(response: URLResponse) {
        print(response)
    }
    
    func createAccount(email: String, password: String, completion: @escaping (User) -> ()) {
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
            let user = try! JSONDecoder().decode(User.self, from: data!)
            
            DispatchQueue.main.async {
                completion(user)
            }
            
        }
        .resume()
    }
    
    
    func login(email: String, password: String, completion: @escaping (User) -> ()) {
        loginFailed = false
        guard let url = URL(string: "https://blue-aerie.herokuapp.com/api/v1/entrance/login") else {
            return
        }
        let cleanEmail = email.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = "emailAddress=\(cleanEmail!)&password=\(password)&rememberMe=false".data(using: .utf8)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    print("\(String(describing: error))")
                    self.loginFailed = true
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                DispatchQueue.main.async {
                    print("Bad Response")
                    self.loginFailed = true
                }
                return
            }
            
            print(String(describing: httpResponse))
            let account = try! JSONDecoder().decode(User.self, from: data!)
            DispatchQueue.main.async {
                completion(account)
            }
            
        }
        
        .resume()
    }
}
