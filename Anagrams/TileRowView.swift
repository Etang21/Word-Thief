//
//  TileRowView.swift
//  Anagrams
//  Used to view a row of tiles
//
//  Created by Eric Tang on 9/11/17.
//  Copyright © 2017 Eric Tang. All rights reserved.
//

import UIKit

protocol TileRowViewDelegate {
    func tileRowViewWasTapped(trView: TileRowView)
}

class TileRowView: UIView {
    
    var tiles = [TileView]()
    var tapDelegate:TileRowViewDelegate?
    
    func addTile(tile: TileView) {
        if tiles.contains(tile) {
            removeTile(tile: tile)
        }
        tiles.append(tile)
        resizeTiles()
        addSubview(tile)
    }
    
    func removeTile(tile: TileView, removeFromSuperview: Bool = false, resizes: Bool = true) {
        guard tiles.contains(tile) else { return }
        tiles = tiles.filter({ !($0.isEqual(tile)) })
        if removeFromSuperview { tile.removeFromSuperview() }
        resizeTiles()
    }

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
            let Xi = firstX + tileSide*CGFloat(Double(i)*(1+UIConstants.spaceTileRatio))
            let animTime = 0.40 + 0.10*Double(arc4random())/Double(UINT32_MAX)
            UIView.animate(withDuration: animTime, delay: 0.00, options: UIViewAnimationOptions.curveEaseOut, animations: {
                tile.moveTo(newSize: CGSize(width: tileSide, height: tileSide), newOrigin: CGPoint(x: Xi, y: allY))
            })
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        tapDelegate?.tileRowViewWasTapped(trView: self)
    }
    
    private struct UIConstants {
        static let spaceTileRatio = 0.15
        static let maxTileSide = CGFloat(50.0)
    }
}
