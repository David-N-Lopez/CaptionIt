//
//  InviteViewController.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 24/05/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import FacebookShare
import FirebaseDatabase

class FBInviteViewController: UIViewController {
  @IBOutlet weak var tblInvite: UITableView!
  @IBOutlet weak var btnInvite: UIButton!
  
  var groupId = "0"
  var friendsArray = [Any]()
  var IDArray = [String]()
  var listFriends = [Any]()
  var selectedIndex = [Int]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      getAllUsers()
      tblInvite.tableFooterView = UIView()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func viewDidAppear(_ animated: Bool) {
    if AccessToken.current == nil {
      loginButtonClicked()
    }
  }
  
  @IBAction func actionBack(_ sender: Any) {
    self.navigationController?.popViewController(animated: true)
  }
  
  @objc func loginButtonClicked() {
    let loginManager = LoginManager()
    loginManager.logIn(readPermissions: [ .publicProfile, .email, .userFriends ], viewController: self) { (loginResult) in
      switch loginResult {
      case .failed(let error):
        print(error)
        self.navigationController?.popViewController(animated: true)
      case .cancelled:
        print("User cancelled login.")
        self.navigationController?.popViewController(animated: true)
      case .success(let grantedPermissions, let declinedPermissions, let accessToken):
        
        self.getFBUserData()
      }
    }
    
  }
  
  //function is fetching the user data
  func getFBUserData(){
    if(AccessToken.current != nil){
      FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id"]).start(completionHandler: { (connection, result, error) -> Void in
        if (error == nil){
          self.getFBFriendsData()
          if let response = result as? [String : Any] {
            if let facebookID = response["id"] as? String {
              if let userId = getUserId() {
                ref.child("Users").child(userId).child("facebookID").setValue(facebookID)
              }
            }
          }
        }
      })
    }
  }
  
  func getFBFriendsData() {
    if AccessToken.current != nil {
      FBSDKGraphRequest(graphPath: "/me/friends", parameters: ["fields": "data"]).start(completionHandler: { (connection, result, error) -> Void in
        if (error == nil) {
          print(result ?? "Na na")
          if let response = result as? [String: Any] {
            if let userId = response["data"] as? [[String: Any]] {
              for dic in userId {
                self.IDArray.append(dic["id"] as! String)
              }
            }
          }
          self.filterFriends()
        }
      })
    }
  }
  
  func filterFriends() {
    for friend in friendsArray {
      let friendResponse = friend as! [String : Any]
      if let facebookID = friendResponse["facebookID"] as? String {
        if IDArray.contains(facebookID) {
          listFriends.append(friend)
        }
        
      }
    }
    selectedIndex.removeAll()
    tblInvite.reloadData()
  }
  
  func getAllUsers() {
    ref.child("Users").observeSingleEvent(of: .value, with: { snapshot in
      if let friends =  snapshot.value as? [String : Any] {
        let allKeys = (friends as NSDictionary).allKeys
        for key in allKeys {
          let responseKey = key as! String
          if let friendDetail = friends[responseKey] as? [String : Any ] {
          self.friendsArray.append(friendDetail)
          }
        }
        if AccessToken.current != nil {
          self.getFBFriendsData()
        }
      }
    })
  }
  @IBAction func actionSendInvite(_ sender: Any) {
    print(selectedIndex)
    for index in selectedIndex {
      let friendDetail = listFriends[index] as! [String: Any]
      if let token = friendDetail["token"] as? String {
        let inviteMessage = "\(Constant.NotifyToJoin) \(self.groupId)"
        PushNotificationManager.notifyToJoin(deviceToken: token, gameID: self.groupId, taskMessage: inviteMessage)
      }
    }
    self.navigationController?.popViewController(animated: true)
  }
  
}
