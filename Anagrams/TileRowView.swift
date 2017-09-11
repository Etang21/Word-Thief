//
//  TileRowView.swift
//  Anagrams
//  Used to view a row of tiles
//
//  Created by Eric Tang on 9/11/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import UIKit

class TileRowView: UIView {
    
    var tiles: [TileView]
    
    init(tiles: [TileView]) {
        self.tiles = tiles
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0)) //Dud frame, will get resized
    }
    
    func resizeTiles() {
        //Resizes and positions tiles within this row view
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Use init(tiles:)")
    }
}
