//
//  JudgementVC.swift
//  CaptionIt
//
//  Created by veera jain on 03/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage
import FirebaseAuth

class JudgementVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
  var usersComments = [Any]()
  var groupId = String()
  var judgeID = String()
  var judgeName = String()
  var memeURL = String()
  
  var hasBeenJudgeRef: DatabaseReference?
  
  @IBOutlet weak var captionTableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    hasBeenJudgeRef = ref.child("rooms").child(groupId).child("players").child(judgeName).child("hasBeenJudge")
    getAllComments()
    observerGameFinish()
    captionTableView.dataSource = self
    captionTableView.delegate = self
    captionTableView.estimatedRowHeight = 300
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    hasBeenJudgeRef?.removeAllObservers()
  }
  
  func getAllComments()  {
    ref.child("rooms").child(self.groupId).child("comments").child(self.judgeID).observeSingleEvent(of: .value, with: { (snapshot) in
      if let comment = snapshot.value as? [String: Any] {
        let allKeys = (comment as NSDictionary).allKeys
        self.usersComments.removeAll()
        for key in allKeys {
          let userId = key as! String
          let user = ["id" : key,
                      "comment" : comment[userId]]
          self.usersComments.append(user)
        }
        self.captionTableView.reloadData()
        
      }
      
    })
  }
  
  //MARK: ACTIONS
  
  @objc func rewardPlayerAction(_ sender:UIButton)  {
    sender.setImage(#imageLiteral(resourceName: "Yello"), for: .normal)
  
    // perform further actions
    let userCommentDic = usersComments[sender.tag] as! [String: String]
    ref.child("rooms").child(self.groupId).child("players").child(userCommentDic["id"]!).child("score").observeSingleEvent(of: .value, with: { (snapshot) in
      if let score = snapshot.value as? Int {
        ref.child("rooms").child(self.groupId).child("players").child(userCommentDic["id"]!).child("score").setValue(score + 1)
      } else {
        ref.child("rooms").child(self.groupId).child("players").child(userCommentDic["id"]!).child("score").setValue(1)
      }
      self.hasBeenJudgeRef?.setValue(true)
    })
    
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return usersComments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let userCommentDic = usersComments[indexPath.row] as! [String: String]
    let captionCell = captionTableView.dequeueReusableCell(withIdentifier: "captionCell", for: indexPath) as! CaptionCell
    captionCell.memeImageView.sd_setImage(with: URL(string:self.memeURL), placeholderImage: nil, options: .scaleDownLargeImages, completed: nil)
    captionCell.lblCaption.text = userCommentDic["comment"]
    if self.judgeID == Auth.auth().currentUser?.uid {
      captionCell.btnReward.isHidden = false
      
    } else {
      captionCell.btnReward.isHidden = true
    }
    captionCell.btnReward.tag = indexPath.row
    captionCell.btnReward.addTarget(self, action: #selector(self.rewardPlayerAction(_:)), for: .touchUpInside)
    return captionCell
    
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return UITableViewAutomaticDimension
  }
  
  func observerGameFinish()  {
    
    hasBeenJudgeRef?.observe(.value, with: { (snapshot) in
      if let gameFinished = snapshot.value as? Bool {
        if gameFinished == true {
          self.hasBeenJudgeRef?.removeAllObservers()
          self.performSegue(withIdentifier: "game_Over", sender: self)
        }
      }
    })
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "game_Over" {
      if let destinationVC = segue.destination as? CaptioningVC {
        destinationVC.curPin = self.groupId
        
      }
    }
  }
  
}

