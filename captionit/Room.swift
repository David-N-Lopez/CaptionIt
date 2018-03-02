//
//  Room.swift
//  CaptionIT
//
//  Created by Thorpe Center on 11/19/17.
//  Copyright © 2017 Thorpe Center. All rights reserved.
//

import Foundation

class Room {
    var playerArray: [Player] = []
    let PIN: String?
    
    func uploadMemefrom(playerNum: Int) {
        //firebase code to upload Meme under player name at that index in the array TRY getting player num with button sender
        let playerWMeme = playerArray[playerNum]
        playerWMeme.ready = true
    }
    func startGame()->Game? {
        
        var readyPlayerArray:[Player] = []
        for playerCheck in playerArray{
            if playerCheck.ready {
                //got to check that the player at given index isnt repeated
                readyPlayerArray.append(playerCheck)
            }
        }
        if readyPlayerArray.count >= 3 {
            return Game(players: readyPlayerArray)
        }
        else {
            return nil
        }
    }
    /*init(player:Player) {
     self.playerArray.append(player)
     
     }*/
    init(PIN:String?){
        self.PIN = PIN
    }
    /*func setNewPlayer(player:Player){
     self.playerArray.append(player)
     }*/
    //NOTE: Working with arrays might not be the best idea because of the indexing
    
}
