//
//  ComputerOpponent.swift
//  Anagrams
//  
//  This class generates steals and time delays for a given board setup, so the player can play against them
//  Has adjustable time difficulty (how quick it responds), and intelligence difficulty (how many steals it sees)
//
//  Created by Eric Tang on 8/28/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import UIKit
import Foundation

class ComputerOpponent {
    
    //MARK: Board Info
    var boardLetters: [Character] = []
    var boardWords: [String] = []
    var stealDelay: Double
    var printsInfo: Bool
    var engLang: Set<String> = []
    
    ///Takes board information and difficulties which range from 0 to 1. printsInfo used for viewing console.
    init(stealDelayInSeconds: Double, printsInfo: Bool = true) {
        self.stealDelay = stealDelayInSeconds
        self.printsInfo = printsInfo
        DispatchQueue.global(qos: .utility).async {
            self.engLang = readScrabbleDict()
        }
    }
    
    ///Returns the first steal that the computer finds. Faster than getBestSteal().
    public func getFirstSteal() -> String? {
        print("In the method getFirstSteal()")
        for word in engLang {
            if(checkSteal(str: word)) {
                if(printsInfo) { print("First steal found: \(word)") }
                return word
            }
        }
        if(printsInfo) { print("No steals found") }
        return nil
    }
    
    ///Used for viewing the best steals later on. Finds longest steal. Slow.
    public func getBestSteal() -> String? {
        let bestSteal = getAllSteals()[0]
        if(printsInfo) { print("Best steal: \(bestSteal)") }
        return bestSteal
    }
    
    ///Returns sorted array of all steals, with longest at the front, prints if printsInfo is on. Slow.
    func getAllSteals() -> [String] {
        var allSteals: [String] = []
        for word in engLang {
            if(checkSteal(str: word)) {
                allSteals.append(word)
            }
        }
        
        allSteals.sort(by: { str1, str2 in
            str1.characters.count > str2.characters.count
        })
        
        if(printsInfo) { print("Steals: \(allSteals)") }
        return allSteals
    }
    
    //MARK: Internal functions to find steals
    private func checkSteal(str: String) -> Bool {
        let strLength = str.characters.count
        guard strLength >= GameSettings.minWordLength else { return false }
        for boardWord in boardWords {
            let boardWordLength = boardWord.characters.count
            if(strLength <= boardWordLength || strLength > boardWordLength + boardLetters.count) { continue }
            if(isStealOfWord(root: boardWord, steal: str)) { return true }
        }
        return isStealOfWord(root: "", steal: str)
    }
    
    private func isStealOfWord(root: String, steal: String) -> Bool {
        guard steal.characters.count >= GameSettings.minWordLength else { return false }
        let rootChars = root.characters
        var stealChars = steal.characters
        var boardChars = boardLetters
        for rootChar in rootChars {
            guard let stlIndex = stealChars.index(of: rootChar) else { return false }
            stealChars.remove(at: stlIndex)
        }
        if stealChars.count == 0 { return false }
        for stlChar in stealChars {
            guard let boardIndex = boardChars.index(of: stlChar) else { return false }
            boardChars.remove(at: boardIndex)
        }
        return true
    }
    
    //MARK: Testing functions
    public func testScrabbleDict() {
        print("We have \(engLang.count) words")
        let testWords = ["WORD", "STEAL", "ALBATROSS", "ALSDBIOURE", "IOPREQW"]
        print("These are real words: \(engLang.intersection(testWords))")
    }
    
    struct GameSettings {
        static let minWordLength = 4
    }
}

///Reads the ScrabbleDictionary.txt file
func readScrabbleDict() -> Set<String> {
    guard let path = Bundle.main.path(forResource: "ScrabbleDictionary", ofType: "txt") else { return [] }
    do {
        let data = try String(contentsOfFile: path, encoding: .utf8)
        let wordArray = data.components(separatedBy: .newlines)
        return Set<String>(wordArray)
    }
    catch {
        print(error)
    }
    return []
}






















