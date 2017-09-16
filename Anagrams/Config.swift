//
//  Config.swift
//  Anagrams
//  Used for truly global constants.
//
//  Created by Eric Tang on 9/15/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

let SoundTap = "tap.wav"
let SoundPlayerSteal = "win.mp3"
let SoundAddLetter = "swoosh.wav"
let SoundOppSteal = "failure-heavy.wav"
let SoundRejectedSteal = "failure-light.wav"

let AudioEffectFiles = [SoundTap, SoundPlayerSteal, SoundAddLetter, SoundOppSteal, SoundRejectedSteal]

let DefaultBackgroundColor = FlatRed()
let ColorArray = ColorSchemeOf(ColorScheme.analogous, color: DefaultBackgroundColor, isFlatScheme: true)

let EntryViewsColor = ColorArray[0] 
let EntryBackgroundColor = ColorArray[2]
let DefaultEntryViewColor = ColorArray[4]
