//
//  AppSetting.swift
//  Swipe2Clean
//
//  Created by Mukesh Muteja on 25/02/18.
//  Copyright © 2018 Swipe2Clean. All rights reserved.
//

import UIKit

class AppSetting: NSObject {
  static var isUserLogin = UserDefaults.standard.bool(forKey: "user_loggedin", default: false) {
    didSet {
      UserDefaults.standard.set(isUserLogin, forKey: "user_loggedin")
    }
  }
}
