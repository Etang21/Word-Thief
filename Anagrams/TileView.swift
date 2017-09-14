//
//  TileView.swift
//  Anagrams
//
//  Created by Eric Tang on 9/11/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import UIKit

protocol TileViewDelegate {
    func tileViewWasTapped(tileView: TileView)
}

class TileView: UIImageView {
    
    var letter: Character
    var charLabel: UILabel!
    var touchDelegate: TileViewDelegate?
    
    init(letter: Character, sideLength: CGFloat) {
        self.letter = letter
        
        let image = UIImage(named: "tile")! //TODO: Have different images for their tiles and yours?
        super.init(image: image)
        self.frame = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)
        self.isUserInteractionEnabled = true
        
        //Add character to tile:
        charLabel = UILabel(frame: self.bounds)
        charLabel.text = String(letter).uppercased()
        charLabel.textAlignment = .center
        charLabel.textColor = UIColor.white
        charLabel.backgroundColor = UIColor.clear
        charLabel.font = UIFont.boldSystemFont(ofSize: 0.618 * sideLength)
        self.addSubview(charLabel)
    }
    
    func moveTo(newSize: CGSize, newOrigin: CGPoint) {
        frame.size = newSize
        frame.origin = newOrigin
        charLabel.font = UIFont.boldSystemFont(ofSize: 0.618 * newSize.width)
        charLabel.frame = self.bounds
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        touchDelegate?.tileViewWasTapped(tileView: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(letter: ,sideLength: )")
    }
    
}
