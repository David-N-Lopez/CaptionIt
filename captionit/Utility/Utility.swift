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

func getReportCount(userId : String, respone:@escaping (_ count : [String:Any]?)->()) {
  ref.child("Users").child(userId).child("report").observeSingleEvent(of: .value, with: { snapshot in
    if let count = snapshot.value as? [String:Any] {
      respone(count)
    } else {
      respone(nil)
    }
  })
}

func updateReport(userId : String, count: Int) {
  ref.child("Users").child(userId).child("report").child("count").setValue(count)
  ref.child("Users").child(userId).child("report").child("reportedBy").child(getUserId()!).setValue(1)
}
