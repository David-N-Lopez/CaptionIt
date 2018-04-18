//
//  WaitingViewController.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 03/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import FirebaseAuth

class WaitingViewController: UIViewController {
  var groupId = String()
  var judgeID = String()
  var judgeName = String()
  var memeURL = String()
  var mediaType = 1
  var round = 0
  var totalUser = 0
  
    @IBOutlet weak var pamaFriendsGif: UIImageView!
    @IBOutlet weak var gifView: UIImageView!
    override func viewDidLoad() {
    super.viewDidLoad()
    observeUsersComments()
      Group.singleton.startTime()
    gifView.image = UIImage.gifImageWithName(name: "pama-waiting-screen (2)")
    pamaFriendsGif.image = UIImage.gifImageWithName(name: "pama-and-friends")
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(self.alertErroOccured),
        name: NSNotification.Name(rawValue: errorOccured),
        object: nil)
  }
    
  func observeUsersComments() {
    let userId = Auth.auth().currentUser?.uid
    
    ref.child("rooms").child(groupId).child("comments").child(userId!).observe(.value, with: { (snapshot) in
      
      if let comment = snapshot.value as? [String: Any] {
        print(comment)
        let allKeys = (comment as NSDictionary).allKeys
        if allKeys.count == self.totalUser - 1 {
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
      }
    })
  }
  
  func alertErroOccured() {
    let controller = UIAlertController(title: "Error: something went wrong", message: "One of your friends unexpectedly left the game.s", preferredStyle: .alert)
    let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
//      self.performSegue(withIdentifier: "leaveSegue", sender: self)
      self.navigationController?.popToRootViewController(animated: true)
    }
    controller.addAction(action)
    self.present(controller, animated: true, completion: nil)
  }
  
  //leaveCaptioningSegue
  @IBAction func actionLeaveGame(_ sender : Any) {
    
    let controller = UIAlertController(title: "Wait! the game is still in progress.", message: "Are you sure you want to leave? if you leave, your friends will no longer be able to keep on playing", preferredStyle: .alert)
    let leave = UIAlertAction(title: "Leave", style: .default) { (action) in
      let currentUser = Auth.auth().currentUser?.uid
      ref.child("rooms").child(self.groupId).child("players").child(currentUser!).removeValue()
    }
    let cancel = UIAlertAction(title: "Stay", style: .cancel, handler: nil)
    controller.addAction(leave)
    controller.addAction(cancel)
    self.present(controller, animated: true, completion: nil)
  }
}

