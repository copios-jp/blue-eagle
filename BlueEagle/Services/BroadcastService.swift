//
//  BroadcastService.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2023/01/24.
//

import Foundation

protocol BroadcastableSubject: Encodable {
  var uuid: UUID { get }
}

class BroadcastService {
  
  var subject: BroadcastableSubject
  
  
  init(_ subject: BroadcastableSubject) {
    self.subject = subject
  }
 
  static func broadcast(_ subject: BroadcastableSubject) {
    let service: BroadcastService = .init(subject)
    service.broadcast()
  }
   
  @objc func broadcast() {
    let data: Data = toJson().data(using: .utf8)!
    let channel: String = subject.uuid.uuidString

    API().broadcast(channel: channel, data: data)
  }

  private func toJson() -> String {
    guard let json = try? JSONEncoder().encode(subject)
    else {
      return "{\"error\": \"Training is unencodable\"}"
    }
    return String(data: json, encoding: .utf8)!
  }
}
