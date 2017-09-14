//
//  GameViewController.swift
//  Anagrams
//
//  The main screen from which the game is played.
//
//  Created by Eric Tang on 8/25/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UITextFieldDelegate, TileViewDelegate, TileRowViewDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var boardTilesView: TileRowView!
    @IBOutlet weak var playerWordsView: WordsView!
    @IBOutlet weak var oppWordsLabel: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var oppScoreLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nextLetterButton: UIButton!
    @IBOutlet weak var entryView: TileRowView!
    @IBOutlet weak var entryFieldY: NSLayoutConstraint!
    var inEntryMode: Bool = false
    var rootTRView: TileRowView?
    
    
    //MARK: Model
    var lettersOnBoard = [Character]()
    var playerWords = [String]()
    var oppWords = [String]()
    var playerScore = 0
    var oppScore = 0
    var compOpp: ComputerOpponent? = nil //nil if no opponent
    var hasTimer: Bool = true
    var nextLetterTime: Float = 10.0 //Next letter flipped every nextLetterTime seconds
    private var timer: Timer!
    private var timerProgress: Int = 0 //Stores timer progress, goes to GameSettings.timerDivision-1

    
    //MARK: Setup Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBoardTilesView()
        configureEntryView()
        configureTimer()
        configureStartingWords()
        updateUI()
        testPlayerWordsView()
    }
    
    func configureBoardTilesView() {
        boardTilesView.tapDelegate = self
    }
    
    func configureEntryView() {
        entryFieldY.constant = ((boardTilesView?.frame.height ?? 0) + (boardTilesView?.frame.height ?? 0))/2
    }
    
    func configureTimer() {
        if(hasTimer) {
            let timerInterval = TimeInterval(nextLetterTime/Float(GameSettings.timerDivision))
            timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: incrementTime(timer:))
            timer.tolerance = 0.1*timerInterval
        }
        else {
            progressView.setProgress(0, animated: false)
        }
    }
    
    func configureStartingWords() {
        //oppWords = ["JOKE", "YOUR", "NEAT", "GRAPE", "COUNTRYSIDE"]
        updateModelScore()
        if(compOpp != nil) { updateCompOpp() }
    }
    
    func testPlayerWordsView() {
        let testStr = "KITTEN"
        let tiles = testStr.characters.map({ TileView(letter: $0, sideLength: 0) })
        let _ = tiles.map({ $0.touchDelegate = self })
        let trView = playerWordsView.addWordForTiles(tiles: tiles)
        trView.tapDelegate = self
        if(playerWordsView.words.count == 3) {
            playerWordsView.remove(trView: playerWordsView.words[0])
        }
    }
    
    func testBoardTilesView() {
        /*
        if(boardTilesView?.tiles.count ?? 0 > 4) {
            boardTilesView.removeTile(tile: boardTilesView.tiles[0], removeFromSuperview: true)
        } */
        guard let boardTiles = boardTilesView?.tiles, boardTiles.count == 5 else {
            return
        }
        for tile in boardTiles {
            boardTilesView.removeTile(tile: tile)
            view.addSubview(tile)
        }
        let trView = playerWordsView.addWordForTiles(tiles: boardTiles)
        playerWordsView.resizeWords()
        trView.tapDelegate = self
    }
    
    //MARK: UI Methods
    func updateUI() {
        updateBoardTiles()
        updatePlayerWordLabels()
        updateScoreLabels()
    }
    
    func updatePlayerWordLabels() {
        oppWordsLabel?.text = oppWords.reduce("", { $0 + "\($1)\n" })
    }
    
    func updateScoreLabels() {
        playerScoreLabel.text = "\(playerScore)"
        oppScoreLabel.text = "\(oppScore)"
        playerScoreLabel.bringSubview(toFront: view)
    }
    
    func incrementTime(timer: Timer) {
        timerProgress = (timerProgress+1) % GameSettings.timerDivision
        let progViewVal = Float(timerProgress)/Float(GameSettings.timerDivision)
        if(timerProgress == 0) {
            addLetter(timer)
            progressView.setProgress(1, animated: true)
        }
        else {
            progressView.setProgress(progViewVal, animated: timerProgress != 1)
        }
    }
    
    @IBAction func addLetter(_ sender: Any) {
        
        testBoardTilesView()
        //testPlayerWordsView() //TODO: Remove this code, it just adds kittens
        
        let nextLetter = getRandomLetter()
        lettersOnBoard.append(nextLetter)
        addBoardTileFor(char: nextLetter)
        
        if(compOpp != nil) {
            updateCompOpp()
            letCompOppSteal()
        }
    }
    
    //TODO: Eventually you will wipe out this method!
    func updateBoardTiles() {
        for tile in boardTilesView.tiles {
            tile.removeFromSuperview()
        }
        boardTilesView.tiles = []
        for char in lettersOnBoard {
            addBoardTileFor(char: char)
        }
        boardTilesView.resizeTiles()
    }
    
    func addBoardTileFor(char: Character) {
        let newTile = TileView(letter: char, sideLength: 0)
        newTile.touchDelegate = self
        boardTilesView.addTile(tile: newTile)
    }
    
    //Returns a random capital letter, with respect to letter frequencies
    func getRandomLetter() -> Character {
        let randIndex = Float(arc4random_uniform(10000))/Float(10000)
        var freqSum: Float = 0.0
        for (char, freq) in AlphabetConstants.lettersWithFrequencies {
            freqSum += freq
            if freqSum > randIndex { return char }
        }
        return "?" //If something bad happened . . .
    }
    
    private func removeTileRowView(trView: TileRowView, playerID: playerID) {
        if(playerID == .player) {
            guard let index = playerWordsView.words.index(of: trView) else { return }
            playerWordsView.words.remove(at: index)
            trView.removeFromSuperview()
            playerWordsView.resizeWords()
        }
        else if(playerID == .opp) {
            //TODO: Remove from opp words
        }
    }
    
    private func addTileRowView(trView: TileRowView, playerID: playerID) {
        if(playerID == .player) {
            playerWordsView.addSubview(trView)
            playerWordsView.words.append(trView)
            playerWordsView.resizeWords()
        }
        else if(playerID == .opp) {
            //TODO: add to opp words
        }
    }
    
    func tileRowViewWasTapped(trView: TileRowView) {
        if !inEntryMode {
            switchToEntryMode(trView: trView)
        }
        if inEntryMode && !trView.isEqual(rootTRView) && !trView.isEqual(boardTilesView) {
            switchOutOfEntryMode(trView: trView)
        }
    }
    
    private func switchToEntryMode(trView: TileRowView) {
        inEntryMode = true
        rootTRView = trView
        for subview in view.subviews + playerWordsView.subviews + [view] {
            subview.backgroundColor = UIColor.lightGray
        }
        trView.backgroundColor = UIColor.green
        boardTilesView.backgroundColor = UIColor.green
        entryView.backgroundColor = UIColor.green
    }
    
    private func switchOutOfEntryMode(trView: TileRowView) {
        inEntryMode = false
        rootTRView = nil
        for subview in view.subviews + playerWordsView.subviews + [view] {
            subview.backgroundColor = UIColor.white
        }
        entryView.backgroundColor = UIColor.gray
    }
    
    func tileViewWasTapped(tileView: TileView) {
        print("Recorded tap, in tileViewWasTapped")
        guard inEntryMode else { return }
        print("In tileViewWasTapped, not in entry mode")
        if let root = rootTRView, root.tiles.contains(tileView) {
            print("Tile detected in the root")
            root.removeTile(tile: tileView)
            entryView.addTile(tile: tileView)
        }
        else if boardTilesView.tiles.contains(tileView) {
            print("Tile detected in boardtiles")
            boardTilesView.removeTile(tile: tileView)
            entryView.addTile(tile: tileView)
        }
        //If not in entry mode, ignore. Entry mode triggered by tapping rows, not tiles
    }
    
    //MARK: Stealing Words
    
    //Submits a steal, and updates model, UI, and compOpp
    public func submitSteal(_ str: String?, isPlayerSteal: Bool) {
        guard let str = str else { return }
        let isSteal = checkSteal(str, isPlayerSteal: isPlayerSteal)
        if(isSteal) {
            if(compOpp != nil) { updateCompOpp() }
            if(isPlayerSteal) {
                //Yay! Fancy bells and whistles you stole it
            }
            else {
                //Oh no the computer stole it :( sad sound effects
            }
        }
        else if(isPlayerSteal) {
            //Player just tried and failed to steal. Do something sad.
        }
        updateUI()
    }
    
    ///Updates computer opponent with new data
    func updateCompOpp() {
        guard compOpp != nil else { return }
        compOpp!.boardLetters = lettersOnBoard
        compOpp!.boardWords = oppWords + playerWords
    }
    
    ///Checks if valid steal, updates model accordingly.
    private func checkSteal(_ str: String, isPlayerSteal: Bool) -> Bool {
        guard str.characters.count >= GameSettings.minWordLength else {return false}
        guard isRealWord(str.lowercased()) else { return false }
        
        for boardWord in oppWords + playerWords + [""] {
            if let newBoardChars = isStealOfWord(root: boardWord, steal: str) {
                updateWordArrays(root: boardWord, steal: str, isPlayerSteal: isPlayerSteal)
                lettersOnBoard = newBoardChars
                updateModelScore()
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
        guard steal.characters.count >= GameSettings.minWordLength else { return nil }
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
    
    //Updates score in model, using scoreDict's score code
    func updateModelScore() {
        oppScore = oppWords.reduce(0, {$0 + (GameSettings.chillScoreDict[$1.characters.count] ?? 12)})
        playerScore = playerWords.reduce(0, {$0 + (GameSettings.chillScoreDict[$1.characters.count] ?? 12)})
    }
    
    //MARK: Computer Opponent Methods
    func printAllSteals() {
        DispatchQueue.global(qos: .utility).async {
            print(self.compOpp?.getAllSteals() ?? "CompOpp is nil")
        }
    }
    
    func letCompOppSteal() {
        DispatchQueue.global(qos: .utility).async {
            guard let compSteal = self.compOpp?.getFirstSteal() else { return }
            //TODO: Add the time delay back in!
            DispatchQueue.main.asyncAfter(deadline: .now() + (self.compOpp?.stealDelay ?? 0), execute: {
                self.submitSteal(compSteal, isPlayerSteal: false)
            })
        }
    }

    //MARK: Constants
    private struct AlphabetConstants {
        static let lettersWithFrequencies: [(char: Character, freq: Float)] = [("A", 0.0816), ("B", 0.0149), ("C", 0.0278), ("D", 0.0425), ("E", 0.1270), ("F", 0.0222), ("G", 0.0201), ("H", 0.0609), ("I", 0.0696), ("J", 0.0015), ("K", 0.0077), ("L", 0.0402), ("M", 0.0240), ("N", 0.0675), ("O", 0.0751), ("P", 0.0193), ("Q", 0.0009), ("R", 0.0599), ("S", 0.0632), ("T", 0.0906), ("U", 0.0276), ("V", 0.0098), ("W", 0.0236), ("X", 0.0015), ("Y", 0.0197), ("Z", 1)] //Ends in 1 to prevent rounding errors
    }
    
    private struct GameSettings {
        static let minWordLength = 4
        static let properScoreDict = [ 1:1, 2:1, 3:1, 4:1, 5:2, 6:3, 7:4, 8:5, 9:6, 10:7, 11:8, 12:9, 13:10, 14:11, 15:12] //wordLength:score
        static let chillScoreDict = [1:1, 2:2, 3:3, 4:4, 5:5, 6:6, 7:7, 8:8, 9:9, 10:10, 11:11, 12:12, 13:13, 14:14, 15:15]
        static let timerDivision: Int = 200 //What fraction of the nextLetterTime the timer updates. Higher -> smoother timer performance.
    }
}

///A tile or char can either be on the board leters, the entry bar, or the root word getting stolen.
enum LetterPosition {
    case board
    case entry
    case root
}

enum playerID {
    case player
    case opp
}
