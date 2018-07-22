//
//  CarouselMemes.swift
//  CaptionIt
//
//  Created by David Lopez on 6/28/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class carouselMemes
{
  // MARK: - Public API
  var title = ""
  var featuredImage: String
  var color: UIColor
  
  init(title: String, featuredImage: String, color: UIColor)
  {
    self.title = title
    self.featuredImage = featuredImage
    self.color = color
  }
  
  // MARK: - Private
  // dummy data
  static func fetchInterests(response:@escaping ( _ success : [carouselMemes])->())
  {
    
    ref.child("memeImages").observeSingleEvent(of: .value, with: { snapshot in
      print(snapshot.value)
      if let arrMeme = snapshot.value as? [String : Any] {
        var arrCarouselMeme = [carouselMemes]()
        let keys = (arrMeme as NSDictionary).allKeys
        for memeKey in keys {
          
          if let memeValue = arrMeme["\(memeKey)"] as? [String : Any] {
            var titleValue = ""
            var featuresImageValue = ""
            var colorValue = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            if let title = memeValue["title"] as? String {
              titleValue = title
            }
            if let featuredImage = memeValue["featuredImage"] as? String {
              featuresImageValue = featuredImage
            }
            if let color = memeValue["color"] as? String {
              colorValue = hexStringToUIColor(hex: color)
            }
            let object = carouselMemes(title: titleValue, featuredImage: featuresImageValue, color: colorValue)
            arrCarouselMeme.append(object)
          }
          
          }
        response(arrCarouselMeme)
        
      }
    })
  }
}
