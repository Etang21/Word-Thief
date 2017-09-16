//
//  AudioController.swift
//  Anagrams
//
//  Created by Eric Tang on 9/15/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import AVFoundation

class AudioController {
    
    private var audio = [String : AVAudioPlayer]()
    
    func preloadAudioEffects() {
        for effect in AudioEffectFiles {
            let soundURL = Bundle.main.bundleURL.appendingPathComponent(effect)
            do {
                let player = try AVAudioPlayer(contentsOf: soundURL)
                player.numberOfLoops = 0
                player.prepareToPlay()
                audio[effect] = player
            } catch {
                print("Well shit you couldn't load the audio player lol bye")
                assert(false)
            }
        }
    }
    
    func playEffect(name: String) {
        print("Now in playEffect in AudioController")
        guard let player = audio[name] else { return }
        print("Found the audio effect \(name) in audio dict")
        if player.isPlaying {
            player.currentTime = 0
        } else {
            player.play()
        }
    }
    
}
