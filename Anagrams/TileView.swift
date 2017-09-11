//
//  TileView.swift
//  Anagrams
//
//  Created by Eric Tang on 9/11/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import UIKit

class TileView: UIImageView {
    
    var letter: Character
    var charPos: LetterPosition
    var tilePos: LetterPosition
    var charLabel: UILabel!
    
    init(letter: Character, pos: LetterPosition, sideLength: CGFloat) {
        self.letter = letter
        self.charPos = pos
        self.tilePos = pos
        
        let image = UIImage(named: "tile")! //TODO: Have different images for their tiles and yours?
        super.init(image: image)
        self.frame = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)
        
        //Add character to tile:
        charLabel = UILabel(frame: self.bounds)
        charLabel.text = String(letter).uppercased()
        charLabel.textAlignment = .center
        charLabel.textColor = UIColor.white
        charLabel.backgroundColor = UIColor.clear
        charLabel.font = UIFont.boldSystemFont(ofSize: 0.618 * sideLength)
        self.addSubview(charLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(letter: ,pos: )")
    }
    
}
