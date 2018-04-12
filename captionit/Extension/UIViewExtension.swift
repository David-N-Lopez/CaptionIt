//
//  UiViewExtension.swift
//  PackAPunch
//
//  Created by Mukesh Muteja on 26/02/18.
//  Copyright © 2018 Veeran Jain. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class DesignableView: UIView {
    
}

@IBDesignable
class DesignableButton: UIButton {
}

@IBDesignable
class DesignableLabel: UILabel {
}

extension UIView {
    
  @IBInspectable
  var cornerRadius: CGFloat {
    get {
      return layer.cornerRadius
    }
    set {
      layer.cornerRadius = newValue
    }
  }
  
  @IBInspectable
  var borderWidth: CGFloat {
    get {
      return layer.borderWidth
    }
    set {
      layer.borderWidth = newValue
    }
  }
  
  @IBInspectable
  var borderColor: UIColor? {
    get {
      let color = UIColor(cgColor: layer.borderColor!)
      return color
    }
    set {
      layer.borderColor = newValue?.cgColor
    }
  }
  
  @IBInspectable
  var shadowRadius: CGFloat {
    get {
      return layer.shadowRadius
    }
    set {
      layer.shadowColor = UIColor.black.cgColor
      layer.shadowOffset = CGSize(width: 0.5, height: 0.4)
      layer.masksToBounds = false
      layer.shadowOpacity = 0.2
      layer.shadowRadius = 14
//        layer.shadowPath = UIBezierPath.init(roundedRect: self.bounds, cornerRadius: cornerRadius).cgPath
        layer.shouldRasterize = true
    }
  }
  
}
