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
    
    func resizeWords() {
        print("We are in resizeWords() and words is \(words)")
        let numWords = words.count
        let totalWordScale = CGFloat(numWords) + CGFloat(UIConstants.spaceWordRatio)*CGFloat(numWords-1)
        let wordHeight = bounds.height/totalWordScale
        
        for i in 0..<numWords {
            let word = words[i]
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
