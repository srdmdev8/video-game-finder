//
//  GameCell.swift
//  VideoGameFinder
//
//  Created by Shawn Moran on 12/30/20.
//

import UIKit

internal final class GameCell: UITableViewCell, Cell {
    // Outlets
    @IBOutlet weak var gameLabel: UILabel!
    @IBOutlet weak var gameImageView: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        gameLabel.text = nil
        gameImageView.image = nil
    }
}
