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
    
    var tiles = [TileView]()

    func resizeTiles() {
        let numTiles = tiles.count
        let totalTileScale = CGFloat(numTiles) + CGFloat(UIConstants.spaceTileRatio)*CGFloat(numTiles-1)
        let maxTileWidth = bounds.width/totalTileScale
        let maxTileHeight = bounds.height
        let tileSide = min(maxTileWidth, maxTileHeight, UIConstants.maxTileSide)
        
        let firstX = bounds.midX - (totalTileScale*tileSide)/2
        let allY = bounds.midY - tileSide/2
        for i in 0..<numTiles {
            let tile = tiles[i]
            tile.frame.size = CGSize(width: tileSide, height: tileSide)
            let Xi = firstX + tileSide*CGFloat(Double(i)*(1+UIConstants.spaceTileRatio))
            tile.frame.origin = CGPoint(x: Xi, y: allY)
            tile.charLabel.font = UIFont.boldSystemFont(ofSize: 0.618 * tileSide)
            tile.charLabel.frame = tile.bounds
        }
    }
    
    private struct UIConstants {
        static let spaceTileRatio = 0.15
        static let maxTileSide = CGFloat(50.0)
    }
}
