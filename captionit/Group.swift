//
//  Group.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 15/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

let errorOccured = "errorOccured"

class Group: NSObject {
  
  static let singleton = Group()
  var curPin = "0"
  var totalUser = 0
  var handle: UInt = 0
  var playersRef: DatabaseReference?
  var gameTimer: Timer!
  
  func observeAnyoneLeftGame(_ groupPin: String) {
    curPin = groupPin
    playersRef = ref.child("rooms").child(groupPin).child("players")
    handle = playersRef!.observe(.childRemoved, with: { (snapshot) in
      let allPlayers = snapshot.children
      
      if let players  = allPlayers.allObjects as? [DataSnapshot]{
        self.playersRef?.removeObserver(withHandle: self.handle)
        print("observer notification sent")
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: errorOccured), object: nil)
      }
    })
  }
  
  func startTime() {
    gameTimer = Timer.scheduledTimer(timeInterval: 300, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
  }
  
  func stopTimer() {
    gameTimer.invalidate()
  self.playersRef?.removeObserver(withHandle: self.handle)
  }
  
  func runTimedCode() {
    stopTimer()
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: errorOccured), object: nil)
   let currentId = Auth.auth().currentUser?.uid
    ref.child("rooms").child(curPin).child("players").child(currentId!).removeValue()
  }
  
  func removeErrorObservers() {
    self.playersRef?.removeObserver(withHandle: self.handle)
    gameTimer.invalidate()
  }
  
}
