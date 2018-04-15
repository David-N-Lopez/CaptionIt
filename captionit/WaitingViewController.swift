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
            self.performSegue(withIdentifier: "judge_Review", sender: self)
        }
      }
    })
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "judge_Review" {
      Group.singleton.stopTimer()
      if let destinationVC = segue.destination as? JudgementVC {
        destinationVC.groupId = groupId
        destinationVC.judgeID = judgeID
        destinationVC.memeURL = memeURL
        destinationVC.judgeName = judgeName
        destinationVC.mediaType = mediaType
        destinationVC.round = round
        destinationVC.totalUser = totalUser
      }
    }
    
  }
  
  func alertErroOccured() {
    let controller = UIAlertController(title: "Error", message: "Something went wrong", preferredStyle: .alert)
    let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
      self.performSegue(withIdentifier: "leaveSegue", sender: self)
    }
    controller.addAction(action)
    self.present(controller, animated: true, completion: nil)
  }
}

