//
//  Player.swift
//  CaptionIt
//
//  Created by Math Lab on 11/20/17.
//  Copyright © 2017 Tower Org. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

class Player {
    var ref:DatabaseReference! = Database.database().reference()
    
    var username:String
    var ready = false
    var roundLikes = 0
    var roundVictories = 0
    var pinNumber: String?//is it necessary?-
    var judge = false
    var hasBeenJudge = false
    var meme = false //stores image from firebase
    
    init (_ username: String){
        self.username = username
    }
    func createGame(curPin: String){
        self.pinNumber = curPin //questionable?
        
        self.ref.child("rooms").child(curPin) //Michael
        self.ref.child("rooms").child(curPin).updateChildValues(["roomPin": curPin])
        joinGame(curPin: curPin)


    }
    
    func joinGame(curPin:String){
        if let currentPlayer = getCurrentPlayer(){
            let playerInfo = ["Ready":self.ready,
                              "judge":self.judge,
                              "meme":self.meme]
            self.ref.child("rooms").child(curPin).child("players").child(currentPlayer.username).updateChildValues(playerInfo)
        }
    }
}

