//
//  ResultVC.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 03/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import Firebase

class ResultVC: UIViewController {
  @IBOutlet weak var tblResult: UITableView!
  var users = [Any]()
  var curPin = String()
  var highestScore = 0
  var userScoreViewed = 0
  var totalUsers = 0
  var viewedRef: DatabaseReference?
  let currentID = Auth.auth().currentUser?.uid
  // Create a storage reference from our storage service
  let storageRef = Storage.storage().reference()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tblResult.tableFooterView = UIView()
    tblResult.backgroundColor = UIColor.white
    viewedRef = ref.child("rooms").child(curPin).child("playersViewed")
    viewedRef?.child(currentID!).setValue(1)
    getAllUsers()
    observeScoreBoardViewed()
    Group.singleton.removeErrorObservers()
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    viewedRef?.removeAllObservers()
  }
  
  func observeScoreBoardViewed() {
    viewedRef?.observe(.value, with: { (snapshot) in
      if let users = snapshot.value as? [String : Any] {
        self.userScoreViewed = users.count
      }
    })
  }
  
  func getAllUsers() {
    ref.child("rooms").child(curPin).child("players").observeSingleEvent(of: .value, with: { (snapshot) in
      if let result = snapshot.children.allObjects as? [DataSnapshot] {
        self.totalUsers = result.count
        for child in result {
          let orderID = child.key
          var value = child.value as! [String : Any]
          value["userName"] = "Undefined User"
          self.users.append(value)
          if orderID == getUserId() {
            if let mediaUrl = value["memeURL"] as? String {
              self.firebaseDeleteMedia(mediaUrl)
            }
          }
          //
        }
        let desc = NSSortDescriptor(key: "score", ascending: false) { // comparator function
          id1, id2 in
          if (id1 as! Int) < (id2 as! Int) { return .orderedAscending }
          if (id1 as! Int) > (id2 as! Int) { return .orderedDescending }
          return .orderedSame
        }
        print(self.users)
        self.users = (self.users as NSArray).sortedArray(using: [desc])
        print(self.users)
        DispatchQueue.main.async {
          self.tblResult.reloadData()
        }
      }
    })
  }
  
  @IBAction func actionFinishGame(_ sender : UIButton) {
    Group.singleton.deleteMediaForGroup()
    if totalUsers == userScoreViewed {
      ref.child("rooms").child(self.curPin).removeValue(completionBlock: { (error, snapshot) in
        self.navigationController?.popToRootViewController(animated: true)
      })
    } else {
      self.navigationController?.popToRootViewController(animated: true)
    }
  }
  
  func firebaseDeleteMedia(_ url : String) {
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
}

extension ResultVC : UITableViewDelegate,UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.users.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
    if let currentUser = users[indexPath.row] as? [String : Any] {
      getUserName(currentUser["ID"] as! String, "Undefined", { (name) in
        cell.name.text = name
      })
      if let score = currentUser["score"] as? Int {
        if indexPath.row == 0 || score == highestScore {
          cell.imageTrophy.isHidden = false
          highestScore = score
        } else {
          cell.imageTrophy.isHidden = true
        }
        cell.score.text = "Score \(score) "
      } else {
        cell.imageTrophy.isHidden = true
        cell.score.text = "Score 0 "
      }
    }
    
    return cell
  }
  
  func getUserName(_ ID : String, _ defaultValue : String, _ response :@escaping (_ name : String) ->()) {
    ref.child("Users").child(ID).observeSingleEvent(of: .value, with: { (snapshot) in
      if let userResponse = snapshot.value as? [String: Any] {
        if let name = userResponse["username"] as? String {
          response(name)
        } else {
          response(defaultValue)
        }
      } else {
        response(defaultValue)
      }
    })
  }
  
}
