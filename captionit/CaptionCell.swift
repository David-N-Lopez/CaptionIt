//
//  CaptionCell.swift
//  CaptionIt
//
//  Created by veera jain on 03/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import AVKit

class CaptionCell: UITableViewCell {
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var btnReward: UIButton!
    var player: AVPlayer?
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpPlayer()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
  func playVideo(url:URL) {
    player = AVPlayer(url: url)
    player?.play()
  }
  
  func setUpPlayer() {
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = self.memeImageView.frame
    self.contentView.layer.addSublayer(playerLayer)
  }
    
}
