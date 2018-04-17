//
//  UIImageExtension.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 16/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
  convenience init(view: DesignableView) {
    UIGraphicsBeginImageContext(view.frame.size)
    view.layer.render(in:UIGraphicsGetCurrentContext()!)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    self.init(cgImage: image!.cgImage!)
  }
}
