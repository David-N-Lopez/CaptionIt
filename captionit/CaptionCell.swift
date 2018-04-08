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
  @IBOutlet weak var viewVideo: UIView!
  
    
    @IBOutlet weak var lblCaption: UILabel!
    @IBOutlet weak var btnReward: UIButton!
    var player: AVPlayer?
  
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
  func playVideo(url:URL) {
    player = AVPlayer.init(url: url)
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = viewVideo.bounds
    viewVideo.layer.addSublayer(playerLayer)
  }
  
    
}
