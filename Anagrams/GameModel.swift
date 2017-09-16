//
//  GameModel.swift
//  Anagrams
//
//  Stores classic information about the game: the board letters, player and opp words
//
//  Created by Eric Tang on 9/14/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import Foundation
import UIKit //Just for the text checker

//Delegate protocol, must react when something is stolen.
protocol GameModelDelegate: class {
    func didSteal(steal: String, root: String, playerID: PlayerID)
}

class GameModel {
    
    var lettersOnBoard = [Character]()
    var playerWords = [String]()
    var oppWords = [String]()
    
    weak var delegate: GameModelDelegate?
    
    var playerScore: Int {
        return playerWords.reduce(0, {$0 + (ModelSettings.chillScoreDict[$1.characters.count] ?? 12)})
    }
    
    var oppScore: Int {
        return oppWords.reduce(0, {$0 + (ModelSettings.chillScoreDict[$1.characters.count] ?? 12)})
    }
    
    ///Checks if valid steal, updates model accordingly.
    public func submitSteal(_ str: String, isPlayerSteal: Bool) -> Bool {
        guard str.characters.count >= ModelSettings.minWordLength else {return false}
        guard isRealWord(str.lowercased()) else { return false }
        
        for boardWord in oppWords + playerWords + [""] {
            if let newBoardChars = isStealOfWord(root: boardWord, steal: str) {
                updateWordArrays(root: boardWord, steal: str, isPlayerSteal: isPlayerSteal)
                lettersOnBoard = newBoardChars
                let stealerID = isPlayerSteal ? PlayerID.player : PlayerID.opp
                delegate?.didSteal(steal: str, root: boardWord, playerID: stealerID)
                return true
            }
        }
        return false
    }
    
    ///Updates the model's word arrays for a given steal
    private func updateWordArrays(root: String, steal: String, isPlayerSteal: Bool) {
        if let pRootIndex = playerWords.index(of: root) {
            playerWords.remove(at: pRootIndex)
        }
        else if let oppRootIndex = oppWords.index(of: root) {
            oppWords.remove(at: oppRootIndex)
        }
        isPlayerSteal ? playerWords.append(steal) : oppWords.append(steal)
    }
    
    //Returns nil if not a steal, and remaining board letters if it is
    func isStealOfWord(root: String, steal: String) -> [Character]? {
        guard steal.characters.count >= ModelSettings.minWordLength else { return nil }
        guard isRealWord(steal.lowercased()) else { return nil }
        
        let rootChars = root.characters
        var stealChars = steal.characters
        var boardChars = lettersOnBoard
        
        for rootChar in rootChars {
            guard let stlIndex = stealChars.index(of: rootChar) else { return nil }
            stealChars.remove(at: stlIndex)
        }
        if stealChars.count == 0 { return nil }
        for stlChar in stealChars {
            guard let boardIndex = boardChars.index(of: stlChar) else { return nil }
            boardChars.remove(at: boardIndex)
        }
        return boardChars
    }
    
    ///Returns true if input is a real English word
    func isRealWord(_ str: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, str.characters.count)
        let misspelled = checker.rangeOfMisspelledWord(in: str, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelled.location == NSNotFound
    }
    
    public var description: String {
        return "lettersOnBoard: \(lettersOnBoard)\nplayerWords: \(playerWords)\noppWords: \(oppWords)"
    }
    
    private struct ModelSettings {
        static let minWordLength = 4
        static let properScoreDict = [ 1:1, 2:1, 3:1, 4:1, 5:2, 6:3, 7:4, 8:5, 9:6, 10:7, 11:8, 12:9, 13:10, 14:11, 15:12] //wordLength:score
        static let chillScoreDict = [1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, 10:10, 11:11, 12:12, 13:13, 14:14, 15:15]
    }
}
