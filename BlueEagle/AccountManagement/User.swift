//
//  User.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/10/03.
//

import Foundation

extension CharacterSet {
    static let rfc3986Unreserved = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
}

func encodeEmail(email: String) -> String {
    guard let clean = email.addingPercentEncoding(withAllowedCharacters: .rfc3986Unreserved) else { return "" }
    return clean
}

struct User: Codable {
    var id: Int
    var fullName: String
    var isSuperAdmin: Bool = false
}
 
struct Signup: Codable {
    var fullName: String
    var emailAddress: String
    var password: String

    func asParams() -> String {
        let emailAddress = encodeEmail(email: self.emailAddress)
      return "emailAddress=\(emailAddress)&fullName=\(self.fullName)&password=\(self.password)"
    }
}
