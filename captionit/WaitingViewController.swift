//
//  WaitingViewController.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 03/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftyGif

class WaitingViewController: UIViewController {
  var groupId = String()
  var judgeID = String()
  var judgeName = String()
  var memeURL = String()
  var mediaType = 1
  var round = 0
  var totalUser = 0
  var totalComments = 0
  var gameTimer: Timer!
  var totalTime = 125
  
  @IBOutlet weak var lblTimer: UILabel!
 
    override func viewDidLoad() {
    super.viewDidLoad()
    observeUsersComments()
      Group.singleton.startTime()
      startTimer()
      lblTimer.text = Group.singleton.timeFormatted(totalTime)
      
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.alertErroOccured(_ :)),
        name: NSNotification.Name(rawValue: errorOccured),
        object: nil)
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.userTimerExpired),
        name: NSNotification.Name(rawValue: timerExpired),
        object: nil)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
    if gameTimer != nil {
      gameTimer.invalidate()
      gameTimer = nil
    }
    let userId = Auth.auth().currentUser?.uid
    ref.child("rooms").child(groupId).child("comments").child(userId!).removeAllObservers()
  }
    
  func observeUsersComments() {
    let userId = Auth.auth().currentUser?.uid
    
    ref.child("rooms").child(groupId).child("comments").child(userId!).observe(.value, with: { (snapshot) in
      
      if let comment = snapshot.value as? [String: Any] {
        print(comment)
        let allKeys = (comment as NSDictionary).allKeys
        self.totalComments = allKeys.count
        if allKeys.count == self.totalUser - 1 {
          self.moveToDestinationVC()
        }
      }
    })
  }
  
  func moveToDestinationVC() {
    let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "JudgementVC") as! JudgementVC
    destinationVC.groupId = self.groupId
    destinationVC.judgeID = self.judgeID
    destinationVC.memeURL = self.memeURL
    destinationVC.judgeName = self.judgeName
    destinationVC.mediaType = self.mediaType
    destinationVC.round = self.round
    destinationVC.totalUser = self.totalUser
    self.navigationController?.pushViewController(destinationVC, animated: true)
  }
  
  func alertErroOccured(_ notification: NSNotification) {
      // do something with your image
      if Group.singleton.totalUser <= 1 {
        let controller = UIAlertController(title: "Error: Something went wrong", message: "All of your friends unexpectedly left the game.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
          Group.singleton.removeErrorObservers()
          Group.singleton.deleteMediaForGroup()
          self.navigationController?.popToRootViewController(animated: true)
        }
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
        return
      } else {
        self.totalUser = Group.singleton.totalUser
        if self.totalComments == Group.singleton.totalUser - 1 {
          self.moveToDestinationVC()
        }
    }
  }
  
  func userTimerExpired()  {
    let controller = UIAlertController(title: "Error", message: "Something went wrong", preferredStyle: .alert)
    let leave = UIAlertAction(title: "Okay", style: .default) { (action) in
      self.navigationController?.popToRootViewController(animated: true)
    }
    controller.addAction(leave)
    self.present(controller, animated: true, completion: nil)
  }
  
  //leaveCaptioningSegue
  @IBAction func actionLeaveGame(_ sender : Any) {
    
    let controller = UIAlertController(title: "Wait! the game is still in progress.", message: "Are you sure you want to leave? if you leave, your friends will no longer be able to keep on playing", preferredStyle: .alert)
    let leave = UIAlertAction(title: "Leave", style: .default) { (action) in
      Group.singleton.removeErrorObservers()
      let currentUser = Auth.auth().currentUser?.uid
      ref.child("rooms").child(self.groupId).child("players").child(currentUser!).removeValue()
      self.navigationController?.popToRootViewController(animated: true)
    }
    let cancel = UIAlertAction(title: "Stay", style: .cancel, handler: nil)
    controller.addAction(leave)
    controller.addAction(cancel)
    self.present(controller, animated: true, completion: nil)
  }
  
  func startTimer() {
    gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
  }
  
  func runTimedCode() {
    if totalTime <= 0 {
      lblTimer.text = Group.singleton.timeFormatted(totalTime)
      gameTimer.invalidate()
      gameTimer = nil
      self.moveToDestinationVC()
    } else {
      totalTime -= 1
      lblTimer.text = Group.singleton.timeFormatted(totalTime)
    }
  }
  
}

