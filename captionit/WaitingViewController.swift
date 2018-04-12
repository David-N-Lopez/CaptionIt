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
  
    @IBOutlet weak var gifView: UIImageView!
    override func viewDidLoad() {
    super.viewDidLoad()
    observeUsersComments()
    gifView.image = UIImage.gifImageWithName(name: "pama-waiting-screen (2)")
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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
}

