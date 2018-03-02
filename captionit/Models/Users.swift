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
    
    static func loginUser(email: String, password: String, callback: ((_ success: Bool, _ user: User?, _ error: Error?) -> Void)?) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            callback?(error == nil, user, error)
        }
    }
}

