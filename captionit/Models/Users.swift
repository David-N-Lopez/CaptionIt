//
//  Users.swift
//  CaptionIt
//
//  Created by KMSOFT on 03/02/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class Users {
    static func registerUser(username: String, email: String, password: String, callback: ((_ success: Bool, _ user: User?, _ error: Error?) -> Void)?) {
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            callback?(error == nil, user, error)
            if(error == nil) {
                let refUser: DatabaseReference! = Database.database().reference()
                let key = refUser.child("Users").child(Auth.auth().currentUser!.uid)
                let caption = ["id": Auth.auth().currentUser!.uid,
                               "username": username]
                key.setValue(caption)
            }
        })
        
    }
  
  static func updateUserName(userName: String,callback: @escaping ((_ success: Bool, _ error: Error?) -> Void)) {
    let refUser: DatabaseReference! = Database.database().reference()
    let key = refUser.child("Users").child(Auth.auth().currentUser!.uid)
    key.child("username").setValue(userName)
    key.child("id").setValue(Auth.auth().currentUser!.uid) { (error, ref) in
      if error == nil {
        callback(true,nil)
      } else {
        callback(false,error)
      }
    }
//    let caption = ["id": Auth.auth().currentUser!.uid,
//                   "username": userName]
//    key.setValue(caption) { (error, reff) in
//      if error == nil {
//        callback(true,nil)
//      } else {
//        callback(false,error)
//      }
//    }
    
  }
    
    static func loginUser(email: String, password: String, callback: ((_ success: Bool, _ user: User?, _ error: Error?) -> Void)?) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            callback?(error == nil, user, error)
        }
    }
}

