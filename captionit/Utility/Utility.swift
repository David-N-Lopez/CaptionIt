//
//  Utility.swift
//  CaptionIt
//
//  Created by KMSOFT on 03/02/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import Foundation


class Utility {
    class func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
