//
//  WordsView.swift
//  Anagrams
//
//  Created by Eric Tang on 9/12/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import UIKit

class WordsView: UIView {
    
    var words = [TileRowView]()
    
    func addWordForTiles(tiles: [TileView]) -> TileRowView {
        //FIXME: This method isn't correctly resizing everything! Some views end up still compressed.
        let trView = TileRowView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: 0)))
        words.append(trView)
        resizeWords()
        self.addSubview(trView)
        for tile in tiles {
            trView.addTile(tile: tile)
        }
        return trView
    }
    
    ///Removes view and all subviews. This assumes you have already moved the tiles elsewhere.
    func remove(trView: TileRowView) {
        guard words.contains(trView) else { return }
        words = words.filter({ !$0.isEqual(trView) })
        trView.tiles = []
        trView.removeFromSuperview()
        resizeWords()
    }
    
    func resizeWords() {
        print("We are in resizeWords() and words is \(words)")
        let numWords = words.count
        let totalWordScale = CGFloat(numWords) + CGFloat(UIConstants.spaceWordRatio)*CGFloat(numWords-1)
        let wordHeight = bounds.height/totalWordScale
        
        for (i, word) in words.enumerated() {
            word.frame.size = CGSize(width: bounds.width, height: wordHeight)
            let Yi = wordHeight*CGFloat(Double(i)*(1+UIConstants.spaceWordRatio))
            word.frame.origin = CGPoint(x: 0, y: Yi)
            word.resizeTiles()
        }
    }
    
    private struct UIConstants {
        static let spaceWordRatio = 0.15
    }
    
}
