//
//  GameCell.swift
//  MySubmissionAdvanced
//
//  Created by Faisal Arif on 06/07/20.
//  Copyright © 2020 Dicoding Indonesia. All rights reserved.
//

import UIKit
import Cosmos
import AVFoundation

class GameCell: UITableViewCell {
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var gameImage: UIImageView!
    @IBOutlet weak var gameName: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var ratingVotes: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var starsView: CosmosView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        gameImage.image = UIImage(named: "default")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        favoriteButton.isSelected = false
    }
}
