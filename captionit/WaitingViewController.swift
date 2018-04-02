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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    observeUsersComments()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func observeUsersComments() {
    let userId = Auth.auth().currentUser?.uid
    
    ref.child("rooms").child(groupId).child("comments").child(userId!).observe(.childAdded, with: { (snapshot) in
      self.performSegue(withIdentifier: "judge_Review", sender: self)
    })
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "judge_Review" {
      if let destinationVC = segue.destination as? JudgementVC {
        destinationVC.groupId = groupId
        destinationVC.judgeID = judgeID
        destinationVC.memeURL = memeURL
        destinationVC.judgeName = judgeName
      }
    }
    
  }
}

