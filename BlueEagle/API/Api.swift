//
//  Api.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2021/12/11.
//

import Foundation

enum DownloadError: Error {
    case statusNotOk
    case decoderError
}

struct Endpoints {
    static let publish = "https://blue-eagle-hide.herokuapp.com/publish/"
    static let qrcode = "https://blue-eagle-hide.herokuapp.com/qr?channel="
    static let observe = "https://blue-eagle-hide.herokuapp.com?channel="
    static let activities = "https://blue-eagle-hide.herokuapp.com/activities.json"
}

struct API {
    
    func get(_ urlString: String, onSuccess: @escaping (Data) -> Void, headers: Dictionary<String, String> = [:] ) {
        let url = URL(string: urlString)!
        
        Task {
            var request = URLRequest(url: url)
            
            for (field, value) in headers {
                request.setValue(value, forHTTPHeaderField: field)
            }
            
            let ( data, response ) = try await URLSession.shared.data(for: request)
            
            guard
                let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200
            else {
                throw DownloadError.statusNotOk
            }
            DispatchQueue.main.async {
                onSuccess(data)
            }
        }
        
    }
    
    func activities(onSuccess: @escaping (Data) -> Void) {
        self.get(Endpoints.activities, onSuccess: onSuccess, headers: ["Content-Type": "application/json"])
    }
    
    func qrcode(_ uuid: String, onSuccess: @escaping (Data) -> Void) {
        self.get(Endpoints.qrcode + uuid, onSuccess: onSuccess)
    }
    
    func broadcast(channel: String, data: Data) {
        Task {
            let url = URL(string: Endpoints.publish + channel)!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = data
            
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
}
