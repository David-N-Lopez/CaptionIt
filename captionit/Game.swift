//
//  Game.swift
//  CaptionIT
//
//  Created by Thorpe Center on 11/19/17.
//  Copyright © 2017 Thorpe Center. All rights reserved.
//

import Foundation

import Foundation

class Game {
    var playerArray:[Player]=[]
    func setNewJudge() {
        /*static*/ var judgeAtIndex = 0
        let newJudge = playerArray[judgeAtIndex]
        newJudge.judge = true
        judgeAtIndex += 1
    }
    init(players:[Player]) {
        self.playerArray.append(contentsOf: players)
    }
    
}
