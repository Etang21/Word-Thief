//
//  GameOverViewController.swift
//  Anagrams
//
//  Created by Eric Tang on 9/17/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {
    
    var gameState: GameModel!
    var winner = PlayerID.player
    
    @IBOutlet weak var winLoseLabel: UILabel!
    @IBOutlet weak var longestWordView: TileRowView!
    @IBOutlet weak var playerLabel: UILabel!
    @IBOutlet weak var oppLabel: UILabel!
    
    override func viewDidLoad() {
        switch winner {
            case .player: winLoseLabel.text = "You Win!"
            case .opp: winLoseLabel.text = "You Lose :["
        }
        print("In viewDidLoad, model is \(gameState.description)")
        playerLabel.text = labelTextForWords(playerID: .player)
        oppLabel.text = labelTextForWords(playerID: .opp)
        
        for char in longestPlayerWord().characters {
            longestWordView.addTile(tile: TileView(letter: char, sideLength: 0))
        }
    }
    
    @IBAction func playAgain(_ sender: Any) {
        performSegue(withIdentifier: SegueIdentifiers.unwindToOpen, sender: self)
    }
    
    private func labelTextForWords(playerID: PlayerID) -> String {
        let score = (playerID == .player) ? gameState.playerScore : gameState.oppScore
        var str = (playerID == .player) ? "Your Score:\n" : "Their Score:\n"
        str = "\(str)\(score)\n"
        let words = (playerID == .player) ? gameState.playerWords : gameState.oppWords
        let wordString = words.reduce("", {"\($0)\($1)\n"})
        return "\(str)\(wordString)"
    }
    
    private func longestPlayerWord() -> String {
        var longestWord = ""
        for word in gameState.playerWords {
            if word.characters.count > longestWord.characters.count {
                longestWord = word
            }
        }
        return longestWord
    }
    
    private struct SegueIdentifiers {
        static let unwindToOpen = "UnwindToOpeningSegue"
    }
}
