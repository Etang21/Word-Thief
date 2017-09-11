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

class GameViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var userInputLabel: UILabel!
    @IBOutlet weak var lettersLabel: UILabel! //This is actually just used for sizing. Could be a view.
    @IBOutlet weak var playerWordsLabel: UILabel!
    @IBOutlet weak var oppWordsLabel: UILabel!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var oppScoreLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nextLetterButton: UIButton!
    @IBOutlet weak var textFieldY: NSLayoutConstraint!
    var boardTiles = [TileView]()
    var entryTiles = [TileView]()
    
    
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
        configureTextField()
        configureTimer()
        configureStartingWords()
        updateUI()
    }
    
    func configureTextField() {
        self.textField?.delegate = self
        textFieldY.constant = ((lettersLabel?.frame.height ?? 0) + (nextLetterButton?.frame.height ?? 0))/2
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.keyboardType = .alphabet
        textField.keyboardAppearance = .default
        textField.returnKeyType = .go
        textField.clearsOnBeginEditing = true
        textField.clearsOnInsertion = true
        //Moves textfield when keyboard shows and hides:
        //NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notif:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notif:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
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
        oppWords = ["JOKE", "YOUR", "NEAT", "GRAPE", "BOMBARD", "COUNTRYSIDE"]
        updateModelScore()
        if(compOpp != nil) { updateCompOpp() }
    }
    
    ///Will be used if we need to shift frame when keyboard appears. Not currently used.
    func keyboardWillShow(notif: NSNotification) {
        //FIXME: Make this better! Actually extract the keyboard height. Animate. Maybe change constraints instead of view? Make it overlay opponents' words?
        let userInfo = notif.userInfo!
        let keyboardFrame: CGRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.view.frame.origin.y = -(keyboardFrame.size.height)
    }
    
    func keyboardWillHide(notif: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    //MARK: UI Methods
    func updateUI() {
        updateBoardTiles()
        updatePlayerWordLabels()
        updateScoreLabels()
    }
    
    func updatePlayerWordLabels() {
        playerWordsLabel?.text = playerWords.reduce("", { $0 + "\($1)\n" })
        oppWordsLabel?.text = oppWords.reduce("", { $0 + "\($1)\n" })
    }
    
    func updateScoreLabels() {
        playerScoreLabel.text = "\(playerScore)"
        oppScoreLabel.text = "\(oppScore)"
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
    
    func updateBoardTiles() {
        for tile in boardTiles {
            tile.removeFromSuperview()
        }
        boardTiles = []
        for char in lettersOnBoard {
            addBoardTile(char: char)
        }
        resizeBoardTiles()
    }
    
    @IBAction func addLetter(_ sender: Any) {
        let nextLetter = getRandomLetter()
        lettersOnBoard.append(nextLetter)
        updateBoardTiles()
        
        if(compOpp != nil) {
            updateCompOpp()
            letCompOppSteal()
        }
    }
    
    ///Updates the board char buttons to fit onscreen and be centered
    func resizeBoardTiles() {
        let numTiles = boardTiles.count
        let totalTileScale = CGFloat(numTiles) + CGFloat(UIConstants.spaceTileRatio)*CGFloat(numTiles-1)
        let maxTileWidth = lettersLabel.frame.width/totalTileScale
        let maxTileHeight = lettersLabel.frame.height
        let tileSide = min(maxTileWidth, maxTileHeight)
        
        let firstX = lettersLabel.frame.midX - (totalTileScale*tileSide)/2
        let allY = lettersLabel.frame.midY - tileSide/2
        for i in 0..<numTiles {
            let tile = boardTiles[i]
            tile.frame.size = CGSize(width: tileSide, height: tileSide)
            let Xi = firstX + tileSide*CGFloat(Double(i)*(1+UIConstants.spaceTileRatio))
            tile.frame.origin = CGPoint(x: Xi, y: allY)
            tile.charLabel.font = UIFont.boldSystemFont(ofSize: 0.618 * tileSide)
            tile.charLabel.frame = tile.bounds
        }
    }
    
    func addBoardTile(char: Character) {
        let newTile = TileView(letter: char, pos: .board, sideLength: 0)
        view.addSubview(newTile)
        boardTiles.append(newTile)
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
    
    //MARK: UITextFieldDelegate Methods
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        submitSteal(textField.text, isPlayerSteal: true)
        textField.text = nil
        return true
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
    
    private struct UIConstants {
        static let tilesPerRow = 3.0
        static let spaceTileRatio = 0.1
    }
}

///A tile or char can either be on the board leters, the entry bar, or the root word getting stolen.
enum LetterPosition {
    case board
    case entry
    case root
}
