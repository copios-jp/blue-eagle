import AVFoundation

class AudioService: NSObject {
  enum Sounds: String {
    case alarm
  }

  static var shared: AudioService = .init()
    
  private var player: AVAudioPlayer = .init()
  private var audioSession = AVAudioSession.sharedInstance()

  var isPlaying: Bool { player.isPlaying }
  var cache: [Sounds: AVAudioPlayer] = [:]
  func play(_ sound: Sounds) {
    guard let path = Bundle.main.path(forResource: sound.rawValue, ofType: "wav") else {
      print("Sound resource for \(sound) not found")
      return
    }

    let url = URL(fileURLWithPath: path)

    do {
      try audioSession.setCategory(.playback, options: .duckOthers)
        if let player = cache[.alarm] {
            player.play()
        } else {
            let player = try AVAudioPlayer(contentsOf: url)
          
          cache[.alarm] = player
          
          player.delegate = self
          player.prepareToPlay()
          player.play()
          
      }
        } catch let error {
      print(error.localizedDescription)
    }
  }
}

extension AudioService: AVAudioPlayerDelegate {
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    do {
        print("finished")
      try self.audioSession.setActive(false, options: .notifyOthersOnDeactivation)
    } catch let error {
      print(error.localizedDescription)
    }
  }
}
