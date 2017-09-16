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

class GameViewController: UIViewController, TileViewDelegate, TileRowViewDelegate, GameModelDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var boardTilesView: TileRowView!
    @IBOutlet weak var playerWordsView: WordsView!
    @IBOutlet weak var oppWordsView: WordsView!
    @IBOutlet weak var playerScoreLabel: UILabel!
    @IBOutlet weak var oppScoreLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nextLetterButton: UIButton!
    @IBOutlet weak var entryView: TileRowView!
    @IBOutlet weak var entryFieldY: NSLayoutConstraint!
    @IBOutlet weak var entryButton: UIButton!
    
    //MARK: Model
    var gameState = GameModel()
    var compOpp: ComputerOpponent? //nil if no opponent
    
    //MARK: Other UI Properties
    var hasTimer: Bool = true
    var nextLetterTime: Float = 10.0 //Next letter flipped every nextLetterTime seconds
    private var timer: Timer!
    private var timerProgress: Int = 0 //Stores timer progress, goes to GameSettings.timerDivision-1
    private var audioPlayer = AudioController()
    
    //MARK: Entry Mode Variables
    var inEntryMode: Bool = false
    var rootTRView: TileRowView?
    var originalRootTiles: [TileView]?
    
    //MARK: Setup Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBoardTilesView()
        configureEntryView()
        configureTimer()
        configureStartingWords()
        configureAudioPlayer()
        gameState.delegate = self
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
            timer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true, block: { [weak self] (timer: Timer) -> Void in
                self?.incrementTime(timer: timer)
            })
            timer.tolerance = 0.1*timerInterval
        }
        else {
            progressView.setProgress(0, animated: false)
        }
    }
    
    func configureStartingWords() {
        gameState.oppWords = ["FALL", "HOME"]
        let _ = gameState.oppWords.map({ addStartingWordToOppUI(str: $0) })
        if(compOpp != nil) { updateCompOpp() }
        updateScoreLabels()
    }
    
    func configureAudioPlayer() {
        audioPlayer.preloadAudioEffects()
        //Play some welcome noise or something maybe
    }
    
    ///Only used for adding the starting words of the game to oppPlayer
    private func addStartingWordToOppUI(str: String) {
        let tiles = str.characters.map({ TileView(letter: $0, sideLength: 0) })
        let _ = tiles.map({ $0.touchDelegate = self })
        let trView = oppWordsView.addWordForTiles(tiles: tiles)
        trView.tapDelegate = self
        updateScoreLabels()
    }
    
    //MARK: Testing Methods
    
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
    
    private var testModelCounter: Int = 0 //Just used for testing
    func testModel() {
        switch testModelCounter {
        case 0: gameState.oppWords.append("HELLO")
        case 1: gameState.lettersOnBoard.append("R")
        case 2: gameState.lettersOnBoard.append("D")
        case 3: gameState.playerWords.append("ELMO")
        case 4: gameState.lettersOnBoard.append("E")
        case 5: print(gameState.submitSteal("HOLLERED", isPlayerSteal: true))
        case 6: print(gameState.submitSteal("SDFVSDF", isPlayerSteal: true))
        case 7: gameState.lettersOnBoard.append("J")
        case 8: print(gameState.submitSteal("MOLES", isPlayerSteal: false))
        default: break
        }
        testModelCounter += 1
        print(gameState.description)
    }
    
    //MARK: UI Methods
    func updateScoreLabels() {
        playerScoreLabel.text = "\(gameState.playerScore)"
        oppScoreLabel.text = "\(gameState.oppScore)"
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
        let nextLetter = getRandomLetter()
        gameState.lettersOnBoard.append(nextLetter)
        
        audioPlayer.playEffect(name: SoundAddLetter)
        addBoardTileFor(char: nextLetter)
        
        if(compOpp != nil) {
            updateCompOpp()
            letCompOppSteal()
        }
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
    
    func tileRowViewWasTapped(trView: TileRowView) {
        if !inEntryMode {
            startEntryMode(trView: trView)
        }
        if inEntryMode && !trView.isEqual(rootTRView) && !trView.isEqual(boardTilesView) {
            endEntryMode(wasSteal: false)
        }
    }
    
    private func startEntryMode(trView: TileRowView) {
        inEntryMode = true
        rootTRView = trView
        originalRootTiles = trView.tiles
        
        let allViews = view.subviews + playerWordsView.subviews + oppWordsView.subviews + [view]
        let _ = allViews.map({
            $0.backgroundColor = UIColor.gray
        })
        
        let highlightViews: [UIView] = [trView, boardTilesView, entryView, entryButton]
        let _  = highlightViews.map({
            $0.backgroundColor = UIColor.green
        })
        
        playerScoreLabel.backgroundColor = UIColor.clear
        oppScoreLabel.backgroundColor = UIColor.clear
    }
    
    private func endEntryMode(wasSteal: Bool) {
        if !wasSteal {
            audioPlayer.playEffect(name: SoundRejectedSteal)
            resetEntryTiles()
        }
        inEntryMode = false
        originalRootTiles = nil
        rootTRView = nil
        
        let allViews = view.subviews + playerWordsView.subviews + oppWordsView.subviews + [view]
        let _ = allViews.map({
            $0.backgroundColor = UIColor.white
        })
        
        entryView.backgroundColor = UIColor.gray
        playerScoreLabel.backgroundColor = UIColor.clear
        oppScoreLabel.backgroundColor = UIColor.clear
    }
    
    private func resetEntryTiles() {
        guard let originals = originalRootTiles else { return }
        guard let rootView = rootTRView else { return }
        for tile in originals {
            entryView.removeTile(tile: tile)
            rootView.addTile(tile: tile)
        }
        for tile in entryView.tiles {
            entryView.removeTile(tile: tile)
            boardTilesView.addTile(tile: tile)
        }
    }
    
    func tileViewWasTapped(tileView: TileView) {
        guard inEntryMode else { return }
        if let root = rootTRView, root.tiles.contains(tileView) {
            root.removeTile(tile: tileView)
        }
        else if boardTilesView.tiles.contains(tileView) {
            boardTilesView.removeTile(tile: tileView)
        }
        else { return }
        
        entryView.addTile(tile: tileView)
        audioPlayer.playEffect(name: SoundTap)
    }
    
    //MARK: Steals
    
    @IBAction func submitEntrySteal(_ sender: Any) {
        guard inEntryMode else { return }
        guard let rootView = rootTRView else { endEntryMode(wasSteal: false); return }
        guard (rootView.isEqual(boardTilesView) || rootView.tiles.isEmpty) else { endEntryMode(wasSteal: false); return }
        print("Entry steal submitted from button.")
        
        let stealString = String(entryView.tiles.map({ $0.letter }))
        let isSteal = gameState.submitSteal(stealString, isPlayerSteal: true) //Updates the entire model, will delegate to UI if successful steal
        if !isSteal { endEntryMode(wasSteal: false) }
    }
    
    ///The model calls this method when a steal goes through
    func didSteal(steal: String, root: String, playerID: PlayerID) {
        updateCompOpp()
        switch playerID {
            case .player: updateUIForPlayerSteal()
            case .opp: updateUIForOppSteal(steal: steal, root: root)
        }
        updateScoreLabels()
    }
    
    ///Called when the opponent steals something.
    private func updateUIForOppSteal(steal: String, root: String) {
        //Terminate player's steal, if in entry mode:
        if inEntryMode { endEntryMode(wasSteal: false) }
        
        //Loop through to find the root word:
        var rootView: TileRowView! = boardTilesView
        for trView in playerWordsView.words + oppWordsView.words {
            if String(trView.tiles.map({ $0.letter })) == root {
                rootView = trView
            }
        }
        
        //Now gather up all our tiles from the views (kinda dumb, I know. Better to store the trViews somewhere.)
        var stealTiles = [TileView]()
        let stealChars = Array(steal.characters)
        var tilesToTake = boardTilesView.tiles + rootView.tiles
        
        for char in stealChars {
            charSearch: for (i, tile) in tilesToTake.enumerated().reversed() {
                if tile.letter == char {
                    stealTiles.append(tile)
                    tilesToTake.remove(at: i)
                    rootView.removeTile(tile: tile)
                    boardTilesView.removeTile(tile: tile)
                    break charSearch
                }
            }
        }
        
        audioPlayer.playEffect(name: SoundOppSteal)
        updateTilesAndRootViewForSteal(tiles: stealTiles, rootView: rootView, playerID: .opp)
    }
    
    ///Called when a word is successfully stolen by player. Assumes it is from entry screen.
    private func updateUIForPlayerSteal() {
        guard let rootView = rootTRView else { endEntryMode(wasSteal: false); return }
        let stolenTiles = entryView.tiles
        let _ = stolenTiles.map({ entryView.removeTile(tile: $0) })
        
        audioPlayer.playEffect(name: SoundPlayerSteal)
        updateTilesAndRootViewForSteal(tiles: stolenTiles, rootView: rootView, playerID: .player)
        endEntryMode(wasSteal: true)
    }
    
    private func updateTilesAndRootViewForSteal(tiles: [TileView], rootView: TileRowView, playerID: PlayerID) {
        var addToView = playerWordsView
        switch playerID {
            case .player: addToView = playerWordsView
            case .opp: addToView = oppWordsView
        }
        
        let newTRView = addToView?.addWordForTiles(tiles: tiles)
        newTRView?.tapDelegate = self
        
        if oppWordsView.words.contains(rootView) {
            oppWordsView.remove(trView: rootView)
        }
        else if playerWordsView.words.contains(rootView) {
            playerWordsView.remove(trView: rootView)
        }
        
        playerWordsView.resizeWords()
        oppWordsView.resizeWords()
    }
    
    //MARK: Computer Opponent Methods
    func updateCompOpp() {
        guard compOpp != nil else { return }
        compOpp!.boardLetters = gameState.lettersOnBoard
        compOpp!.boardWords = gameState.oppWords + gameState.playerWords
    }
    
    func printAllSteals() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            let allSteals = self?.compOpp?.getAllSteals() ?? ["CompOpp is nil"]
            print(allSteals)
        }
    }
    
    func letCompOppSteal() {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            guard let compSteal = self?.compOpp?.getFirstSteal() else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + (self?.compOpp?.stealDelay ?? 0), execute: {
                self?.gameState.submitSteal(compSteal, isPlayerSteal: false)
            })
        }
    }

    //MARK: Constants
    private struct AlphabetConstants {
        static let lettersWithFrequencies: [(char: Character, freq: Float)] = [("A", 0.0816), ("B", 0.0149), ("C", 0.0278), ("D", 0.0425), ("E", 0.1270), ("F", 0.0222), ("G", 0.0201), ("H", 0.0609), ("I", 0.0696), ("J", 0.0015), ("K", 0.0077), ("L", 0.0402), ("M", 0.0240), ("N", 0.0675), ("O", 0.0751), ("P", 0.0193), ("Q", 0.0009), ("R", 0.0599), ("S", 0.0632), ("T", 0.0906), ("U", 0.0276), ("V", 0.0098), ("W", 0.0236), ("X", 0.0015), ("Y", 0.0197), ("Z", 1)] //Ends in 1 to prevent rounding errors
    }
    
    private struct GameSettings {
        static let timerDivision: Int = 200 //What fraction of the nextLetterTime the timer updates. Higher -> smoother timer performance.
    }
}

enum PlayerID {
    case player
    case opp
}
