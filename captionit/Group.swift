//
//  Group.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 15/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import Firebase

let errorOccured = "errorOccured"
let timerExpired = "timerExpired"
let memeTimerExpired = "memeTimerExpired"

protocol GroupDelegate {
  func memeTimerChanged(_ time : Int)
}

class Group: NSObject {
  
  static let singleton = Group()
  var delegate : GroupDelegate?
  var curPin = "0"
  var totalUser = 0
  var handle: UInt = 0
  var updatedUsers = 0
  var playersRef: DatabaseReference?
  var groupRef: DatabaseReference?
  var gameTimer: Timer!
  var memePickTimer: Timer!
  var users = [Any]()
  var token = ""
  var url = ""
  var judgeID = ""
  var round = 0
  var userIndex = 0
  var memePickerTime = 180
  var isStrange = false
  var isInactive = false
  var isImageUploaded = false
  var timerStarted = 0
  
  func observeAnyoneLeftGame(_ groupPin: String) {
    curPin = groupPin
    self.round = 0
    playersRef = ref.child("rooms").child(groupPin).child("players")
    groupRef = ref.child("rooms").child(groupPin).child("triggerUsers")
    handle = playersRef!.observe(.childRemoved, with: { (snapshot) in
      let allPlayers = snapshot.value
      
      if let players  = allPlayers as? [String : Any] {
        print(players)
        var isJudge = false
        let id = players["ID"] as! String
        if id == self.judgeID {
          isJudge = true
        }
        self.round -= 1
        
        for (index, user) in self.users.enumerated() {
          if let userDic = user as? [String : Any] {
            let userID = userDic["ID"] as! String
            if id == userID {
              self.users.remove(at: index)
            }
          }
        }
        
        if self.totalUser == 1 {
          ref.child("rooms").child(groupPin).removeValue()
          self.deleteMediaForGroup()
        }
        self.playersRef?.observeSingleEvent(of: .value, with: { (snapshot) in
          if let allPlayesInfo = snapshot.value as? [String : Any] {
            let allUsers = (allPlayesInfo as NSDictionary).allKeys
            self.totalUser = allUsers.count
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: errorOccured), object: nil, userInfo: ["isJudge": isJudge])
          }
        })
        self.firebaseDeleteMedia(players["memeURL"] as! String)
        print("observer notification sent")
        //self.playersRef?.removeObserver(withHandle: self.handle)
      }
    })
  }
  
  func groupStartMemePickTimer() {
    memePickTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(memePickerTimeOut), userInfo: nil, repeats: true)
  }
  
  
  func startTime() {
    gameTimer = Timer.scheduledTimer(timeInterval: 8000, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
  }
  
  func stopTimer() {
    gameTimer.invalidate()
  }
  
//  NotificationCenter.default.post(name: NSNotification.Name(rawValue: memeTimerExpired), object: nil)
//  removeUserFromGame()
//  deleteCurrentUserMedia()
  
  func timeFormatted(_ totalSeconds: Int) -> String {
    let seconds: Int = totalSeconds % 60
    let minutes: Int = (totalSeconds / 60) % 60
    //     let hours: Int = totalSeconds / 3600
    return String(format: "%02d:%02d", minutes, seconds)
  }
  
  func memePickerTimerExpired() {
    if let time = memePickTimer {
    time.invalidate()
    }
  }
  
  func memePickerTimeOut() {
    timerStarted = timerStarted + 1
//    if memePickerTime > 0 {
//      memePickerTime = memePickerTime - 1
      if delegate != nil {
        delegate?.memeTimerChanged(timerStarted)
      }
//    } else {
//      if delegate != nil {
//        delegate?.memeTimerChanged(memePickerTime)
//      }
//      if isInactive {
//        memeRunOut()
//      }
//    }
  }
  
  func memeRunOut() {
    memePickTimer.invalidate()
    memePickerTime = 180
    removeUserFromGame()
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: memeTimerExpired), object: nil)
  }
  
  func runTimedCode() {
    stopTimer()
    removeErrorObservers()
    NotificationCenter.default.post(name: NSNotification.Name(rawValue: timerExpired), object: nil)
    deleteMediaForGroup()
    ref.child("rooms").child(curPin).child("players").removeValue()
  }
  
//  func triggerCheckActiveUsers() {
//    groupRef?.observeSingleEvent(of: .value, with: { (snapshot) in
//      if let triggered = snapshot.value as? Bool {
//        self.groupRef?.setValue(!triggered)
//      }
//    })
//  }
  
  func setAllUsersInactive() {
    
  }
  
  func removeErrorObservers() {
    self.playersRef?.removeObserver(withHandle: self.handle)
    if gameTimer != nil {
      gameTimer.invalidate()
    }
  }
  
  func sendNotification(_ message: String) {
    for user in users {
      if let userDic = user as? [String : Any] {
        let id = userDic["ID"] as! String
        if id != getUserId() {
          ref.child("Users").child(id).child("token").observeSingleEvent(of: .value, with: { (snapshot) in
            if let token = snapshot.value as? String {
              PushNotificationManager.sendNotificationToDevice(deviceToken: token, gameID: self.curPin, taskMessage: message)
            }
          })
        }
      }
    }
  }
  
  func sendNotificationToJudge(_ judgeId: String, _ message: String) {
    ref.child("Users").child(judgeId).child("token").observeSingleEvent(of: .value, with: { (snapshot) in
      if let token = snapshot.value as? String {
        PushNotificationManager.sendNotificationToDevice(deviceToken: token, gameID: self.curPin, taskMessage: message)
      }
    })
  }
  
  func startStrangeTimer() {
    self.memePickerTimerExpired()
    ref.child("rooms").child(curPin).observeSingleEvent(of: .value, with: { (snapshot) in
      guard let value = snapshot.value as? [String: Any] else {return}
      if let timeSaved = value["time"] as? Double {
        self.memePickerTimerExpired()
        let converted = NSDate(timeIntervalSince1970: timeSaved / 1000)
        let time = Date().timeIntervalSince(converted as Date)
        self.timerStarted = Int(time)
        self.groupStartMemePickTimer()
        
      } else {
        let time = Date().timeIntervalSince1970
        ref.child("rooms").child(self.curPin).child("time").setValue([".sv": "timestamp"])
        self.timerStarted = 0
        self.memePickerTimerExpired()
        self.groupStartMemePickTimer()
      }
    })
  }
  
 private func firebaseDeleteMedia(_ url : String) {
    let storage = Storage.storage()
    let storageRef = storage.reference(forURL: url)
    //Removes image from storage
    storageRef.delete { error in
      if let error = error {
        print(error)
      } else {
        // File deleted successfully
        
      }
    }
  }
  
  func deleteMediaForGroup() {
    for user in users {
      if let userDic = user as? [String : Any] {
        if let url = userDic["memeURL"] as? String {
        firebaseDeleteMedia(url)
        }
      }
    }
  }
  
  func deleteCurrentUserMedia() {
    if url.count > 0 {
      firebaseDeleteMedia(url)
    }
  }
  
  func removeUserFromGame() {
    if let uid = getUserId() {
     ref.child("rooms").child(curPin).child("players").child(uid).removeValue()
    }
    
  }
 
}
