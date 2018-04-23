//
//  UserdefaultExtension.swift
//  Swipe2Clean
//
//  Created by Mukesh Muteja on 25/02/18.
//  Copyright © 2018 Swipe2Clean. All rights reserved.
//

import Foundation

extension UserDefaults {
  
  func setCodingObject(_ object: Any?, forKey key: String) {
    if object == nil {
      set(nil, forKey: key)
    } else {
      let archived = NSKeyedArchiver.archivedData(withRootObject: object!)
      set(archived, forKey: key)
    }
  }
  
  func codingObject(forKey key: String) -> Any? {
    var result: Any?
    if let data = value(forKey: key) as? Data {
      do {
        try ObjC.catchException {
          result = NSKeyedUnarchiver.unarchiveObject(with: data)
        }
        return result
      }
      catch {}
    }
    return nil
  }
  
  func integer(forKey key: String, default defaultValue: Int?) -> Int? {
    if object(forKey: key) != nil {
      return integer(forKey: key)
    }
    return defaultValue
  }
  
  func float(forKey key: String, default defaultValue: Float?) -> Float? {
    if object(forKey: key) != nil {
      return float(forKey: key)
    }
    return defaultValue
  }
  
  func double(forKey key: String, default defaultValue: Double?) -> Double? {
    if object(forKey: key) != nil {
      return double(forKey: key)
    }
    return defaultValue
  }
  
  func bool(forKey key: String, default defaultValue: Bool?) -> Bool? {
    if object(forKey: key) != nil {
      return bool(forKey: key)
    }
    return defaultValue
  }
  
  func string(forKey key: String, default defaultValue: String?) -> String? {
    if object(forKey: key) != nil {
      return string(forKey: key)
    }
    return defaultValue
  }
}
