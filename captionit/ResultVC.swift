//
//  ResultVC.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 03/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ResultVC: UIViewController {
  @IBOutlet weak var tblResult: UITableView!
  var users = [Any]()
  var curPin = String()
  var highestScore = 0
  
    override func viewDidLoad() {
        super.viewDidLoad()
      tblResult.tableFooterView = UIView()
      tblResult.backgroundColor = UIColor.white
      getAllUsers()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  func getAllUsers() {
    ref.child("rooms").child(curPin).child("players").observeSingleEvent(of: .value, with: { (snapshot) in
      if let result = snapshot.children.allObjects as? [DataSnapshot] {
        for child in result {
          let orderID = child.key
          var value = child.value as! [String : Any]
          value["userName"] = "Undefined User"
          self.users.append(value)
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
    self.performSegue(withIdentifier: "restart_Game", sender: self)
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
