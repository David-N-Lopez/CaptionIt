//
//  User .swift
//  CaptionIT
//
//  Created by Thorpe Center on 11/19/17.
//  Copyright © 2017 Thorpe Center. All rights reserved.
//

import Foundation
import UIKit

class UserData {
    var username: String
    let ID: Int
    var password: String
    var email: String
    init (username: String, ID: Int, password: String, email: String) {
        self.username = username
        self.email = email
        self.password = password
        self.ID = ID
    }
    func initializePlayer() -> Player {
        return Player(self.username)
    }
}


