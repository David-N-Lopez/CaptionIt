//
//  MemeCollectionViewCell.swift
//  CaptionIt
//
//  Created by David Lopez on 6/26/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var editorsMemes: UIImageView!
    @IBOutlet weak var promoLabel: UILabel!
    @IBOutlet weak var overlay: UIView!
    var content: carouselMemes?{
        didSet{
            self.updateUI()
        }
    }
    private func updateUI(){
        if let content = content{
            editorsMemes.image = content.featuredImage
            promoLabel.text = content.title
            overlay.backgroundColor = content.color
        }
        else {
            editorsMemes.image = nil
            promoLabel.text = nil
            overlay.backgroundColor = nil
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 3.0
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 5, height: 10)
        
        self.clipsToBounds = false
    }
}

