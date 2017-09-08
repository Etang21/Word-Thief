//
//  DifficultyViewController.swift
//  Anagrams
//
//  Created by Eric Tang on 8/29/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import UIKit
import Foundation

class DifficultyViewController: UIViewController {
    
    @IBOutlet weak var diffSlider: UISlider!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.computerOpponent {
            guard let destGame = segue.destination as? GameViewController else { return }
            guard let sliderVal = diffSlider?.value else {
                print("Could not get difficulty slider value. Setting delay to 10")
                destGame.compOpp = ComputerOpponent(stealDelayInSeconds: 10)
                return
            }
            destGame.compOpp = ComputerOpponent(stealDelayInSeconds: Double((1-sliderVal)*30))
        }
        
    }
    
    struct SegueIdentifiers {
        static let mellow = "MellowSetupSegue"
        static let computerOpponent = "ComputerOpponentSegue"
    }
}
