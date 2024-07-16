//
//  AudioService.swift
//  BlueEagle
//
//  Created by Randy Morgan on 2024/07/16.
//

import Foundation
import AVFoundation

class AudioService {
    static private var player: AVAudioPlayer?
    
    static func play(_ resource: String) {
        guard let path = Bundle.main.path(forResource: resource, ofType: "wav") else {
          return
        }
        let url = URL(fileURLWithPath: path)

        do {
          player = try AVAudioPlayer(contentsOf: url)
          player?.play()

        } catch let error {
          print(error.localizedDescription)
        }
    }
}
