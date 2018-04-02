//
//  CaptionCell.swift
//  CaptionIt
//
//  Created by veera jain on 03/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit

class CaptionCell: UITableViewCell {
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var btnReward: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
