//
//  UserController.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/21.
//

enum DownloadError: Error {
    case statusNotOk
    case decoderError
}
import Foundation
func buildFormJsonRequest(url: String, body: String) throws -> URLRequest{
    let url = URL(string: "https://blue-aerie.herokuapp.com/api/v1/entrance/signup")!
    
    var request = URLRequest(url: url)
    
    request.httpMethod = "POST"
    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = body.data(using: .utf8)
    
    return request
}

class UserController: ObservableObject {
    
    @Published var user: User? = nil
    @Published var authenticated: Bool = false
    @Published var inFlight: Bool = false
    
    func signup(fullName: String, email: String, password: String) async throws -> Bool {
        
        let body = Signup(fullName: fullName, emailAddress: email, password: password).asParams()
        let url = "https://blue-aerie.herokuapp.com/api/v1/entrance/signup"
        let request = try buildFormJsonRequest(url: url, body: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw DownloadError.statusNotOk
        }
        
        do {
            self.user = try JSONDecoder().decode(User.self, from: data)
        } catch {
            throw DownloadError.decoderError
        }
        
        return true
    }
    
    func signin(email: String, password: String) async throws {
        let url = URL(string: "https://blue-aerie.herokuapp.com/api/v1/entrance/login")!
        let encodedEmail = encodeEmail(email: email)
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = "emailAddress=\(encodedEmail)&password=\(password)&rememberMe=false".data(using: .utf8)
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw DownloadError.statusNotOk
        }
        
        guard let user = try? JSONDecoder().decode(User.self, from: data)
        else {
            throw DownloadError.decoderError
        }
        
        DispatchQueue.main.async {
            if let cookie = HTTPCookie(properties: [
                .domain: "blue-aerie.herokuapp.com",
                .path: "/",
                .name: "sails.sid",
                .value: user.sid,
                .secure: "FALSE",
                .discard: "TRUE"
            ]) {
                HTTPCookieStorage.shared.setCookie(cookie)
                print("Cookie inserted: \(cookie)")
            }
            
            self.user = user
        }
    }
    
}
