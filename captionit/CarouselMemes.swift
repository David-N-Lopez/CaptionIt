//
//  CarouselMemes.swift
//  CaptionIt
//
//  Created by David Lopez on 6/28/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit

class carouselMemes
{
    // MARK: - Public API
    var title = ""
    var featuredImage: UIImage
    var color: UIColor
    
    init(title: String, featuredImage: UIImage, color: UIColor)
    {
        self.title = title
        self.featuredImage = featuredImage
        self.color = color
    }
    
    // MARK: - Private
    // dummy data
    static func fetchInterests() -> [carouselMemes]
    {
        return [
            carouselMemes(title: "Pick one of our memes", featuredImage: #imageLiteral(resourceName: "pizza-pama"), color: UIColor(red: 63/255.0, green: 71/255.0, blue: 80/255.0, alpha: 0.8)),
            carouselMemes(title: "", featuredImage:#imageLiteral(resourceName: "Roll-Safe-Think-About-It"), color: UIColor(red:0 , green: 0, blue: 0, alpha: 0)),
            carouselMemes(title: "", featuredImage: #imageLiteral(resourceName: "meme Zucc"), color: UIColor(red: 0, green: 0, blue: 0, alpha: 0)),
            carouselMemes(title: "", featuredImage: #imageLiteral(resourceName: "NYE-pama"), color: UIColor(red: 0, green: 0, blue: 0, alpha: 0)),
            
            carouselMemes(title: "", featuredImage: #imageLiteral(resourceName: "bee-pama"), color: UIColor(red: 0, green: 0, blue: 0, alpha: 0)),
            carouselMemes(title: "", featuredImage: #imageLiteral(resourceName: "pama"), color: UIColor(red: 0, green: 0, blue: 0, alpha: 0)),
            carouselMemes(title: "", featuredImage:#imageLiteral(resourceName: "snow-pama"), color: UIColor(red: 0, green:0, blue: 0, alpha: 0)),
            carouselMemes(title: "", featuredImage: #imageLiteral(resourceName: "pizza-pama"), color: UIColor(red: 0, green: 0, blue: 0, alpha: 0)),
        ]
    }
}
