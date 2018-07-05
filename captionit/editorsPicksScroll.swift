//
//  editorsPicksScroll.swift
//  CaptionIt
//
//  Created by David Lopez on 6/19/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import Foundation
import UIKit

class editorsPicks: UIViewController {
    @IBOutlet weak var imageViews: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let editorsImages = [#imageLiteral(resourceName: "bee-pama"),#imageLiteral(resourceName: "cat-pama"),#imageLiteral(resourceName: "NYE-pama"),#imageLiteral(resourceName: "pirate-pama"),#imageLiteral(resourceName: "snow-pama"),#imageLiteral(resourceName: "st-pats-pama(1)")]
        for i in 0..<editorsImages.count{
            let imageView = UIImageView()
            imageView.image = editorsImages[i]
            let yPosition = self.view.frame.height * CGFloat(i)
            imageView.frame = CGRect(x:0, y:yPosition,width:self.imageViews.frame.width, height:self.imageViews.frame.height)
        }
        
    }
    
}
