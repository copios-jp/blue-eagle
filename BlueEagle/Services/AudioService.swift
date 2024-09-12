//
//  AudioService.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/16.
//

import AVFoundation

class AudioService {
  static func load(_ resource: String) -> AVAudioPlayer {
    guard let path = Bundle.main.path(forResource: resource, ofType: "wav") else {
      fatalError("Sound resource for \(resource) not found")
    }

    let url = URL(fileURLWithPath: path)

    do {
      let player = try AVAudioPlayer(contentsOf: url)
      player.prepareToPlay()
      return player
    } catch let error {
      print(error.localizedDescription)
      fatalError(error.localizedDescription)
    }
  }
}
