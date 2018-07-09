//
//  ResultCell.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 03/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit

class ResultCell: UITableViewCell {
@IBOutlet weak var name: UILabel!
@IBOutlet weak var score: UILabel!
@IBOutlet weak var imageTrophy: UIImageView!
@IBOutlet weak var playerImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
