//
//  TutorialViewController.swift
//  Anagrams
//
//  Created by Eric Tang on 9/18/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import Foundation
import UIKit
import ChameleonFramework

class TutorialViewController: GameViewController {
    
    var letterSequence = ["A", "B", "C", "D"]
    
    override func viewDidLoad() {
        hasTimer = false
        super.viewDidLoad()
        compOpp = nil
    }

    func welcomePopover() {
        
    }
}
