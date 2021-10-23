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

class UserController: ObservableObject {
    
    @Published var user: User? = nil
    @Published var authenticated: Bool = false
    
    func authenticate(email: String, password: String) async throws -> Bool {
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
        
        do {
          self.user = try JSONDecoder().decode(User.self, from: data)
        } catch {
          throw DownloadError.decoderError
        }
        
        return true
    }

}
