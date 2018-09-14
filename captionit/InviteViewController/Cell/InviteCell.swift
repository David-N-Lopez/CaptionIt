//
//  InviteCell.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 24/05/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit

class InviteCell: UITableViewCell {
  
  @IBOutlet weak var imageSelected: UIImageView!
  @IBOutlet weak var lblName: UILabel!
  @IBOutlet weak var playerImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
