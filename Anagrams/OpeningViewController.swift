//
//  OpeningViewController.swift
//  Anagrams
//
//  Created by Eric Tang on 8/25/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import UIKit
import ChameleonFramework

class OpeningViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = GradientColor(.diagonal, frame: view.frame, colors: [DefaultBackgroundColor, MenuBackgroundColor])
        //self.setStatusBarStyle(UIStatusBarStyleContrast)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.mellow {
            guard let destGame = segue.destination as? GameViewController else { return }
            destGame.compOpp = nil
        }
        if segue.identifier == SegueIdentifiers.computerOpponent {
            guard let destGame = segue.destination as? GameViewController else { return }
            destGame.compOpp = ComputerOpponent(stealDelayInSeconds: 10)
        }
    }
    
    @IBAction func unwindToOpening(segue: UIStoryboardSegue) {
        
    }
    
    struct SegueIdentifiers {
        static let mellow = "MellowSetupSegue"
        static let computerOpponent = "ComputerOpponentSegue"
    }
}

