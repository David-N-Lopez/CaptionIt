//
//  ViewController.swift
//  CaptionIt
//
//  Created by Math Lab on 11/6/17.
//  Copyright © 2017 Tower Org. All rights reserved.
//


import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwiftyGif
import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import FacebookShare

var ref:DatabaseReference! = Database.database().reference()

class ViewController: UIViewController, UITextFieldDelegate {
  var curPin:String = "0000"
  let gifManager = SwiftyGifManager(memoryLimit:10)
  @IBOutlet weak var scubaGif: UIImageView!
  @IBOutlet weak var createGameBtn : UIButton!
  
  
  @IBOutlet weak var pinText: UITextField!
  
  /***************************JOIN AND CREATE BUTTONS****************************/
  
  @IBAction func Join(_ sender: UIButton) {
    
    ref.child("rooms").observeSingleEvent(of: .value, with: { snapshot in
      // I got the expected number of items
      let enumerator = snapshot.children
      
      while let rest = enumerator.nextObject() as? DataSnapshot {
        if let curRoom = rest.childSnapshot(forPath: "roomPin").value as? String {
          if let isStrange = rest.childSnapshot(forPath: "isStrange").value as? Bool {
            var isFull = false;
            if isStrange {
              
              if let isFullGroup = rest.childSnapshot(forPath: "isFull").value as? Bool {
                isFull = isFullGroup
              }
            }
            if (self.pinText.text == curRoom && isFull == false) {
              let userId = Auth.auth().currentUser?.uid
              ref.child("rooms").child(self.pinText.text!).child("comments").child(userId!).removeValue()
              
              self.curPin = self.pinText.text!
              Group.singleton.isStrange = isStrange
              if let currentPlayer = getCurrentPlayer(){
                currentPlayer.joinGame(curPin: curRoom)
                //                        self.performSegue(withIdentifier: "toroom1", sender: self)
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "EnterRoomViewController") as! EnterRoomViewController
                controller.curPin = self.curPin
                self.navigationController?.pushViewController(controller, animated: true)
                return
              }
            }
          }
        }
      }
      //error message
      let alert = UIAlertController(title: "Room doesn't exist", message: "Try creating a new room or re-typing your pin number", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
      self.present(alert, animated: true)
    })//Good
  }
  /*******************create game makes reference to the player function createGame******************/
  
  @IBAction func CreateGame(_ sender: UIButton) {
    let pin = generatePIN() // where to generate Pin? in Player Class???
    curPin = pin!
    Group.singleton.isStrange = false
    if let currentPlayer = getCurrentPlayer(){
      currentPlayer.createGame(curPin: curPin, isStrange: false)
      let controller = self.storyboard?.instantiateViewController(withIdentifier: "EnterRoomViewController") as! EnterRoomViewController
      controller.curPin = curPin
      self.navigationController?.pushViewController(controller, animated: true)
    }
  }
  /*
   
   The segue toroom1 passes the current pin (curPin) and the current player username through the
   prepare for segue function
   
   */
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.pinText.delegate = self
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
    view.addGestureRecognizer(tap)
    Group.singleton.curPin = "0"
    //        scubaGif.image = UIImage.gifImageWithName(name: "scuba-pama")
    let gifManager = SwiftyGifManager(memoryLimit:10)
    let gif = UIImage(gifName: "scuba-pama-final")
    scubaGif.setGifImage(gif, manager: gifManager, loopCount: -1)
    createGameBtn.pulsate()
    checkReportAbuse()
  }
  
  func checkReportAbuse() {
    getReportCount(userId: getUserId()!) { (count) in
      if let values = count {
        if let totalCount = values["count"] as? Int {
          if totalCount >= 10 {
            self.showReportLimitAlert()
          }
        }
      }
    }
    }
  
  func showReportLimitAlert() {
    let controller = UIAlertController(title: "Sorry", message: "Many Users Reported against you", preferredStyle: .alert)
    let okay = UIAlertAction(title: "Okay", style: .cancel) { (action) in
      let deletepermission = FBSDKGraphRequest(graphPath: "me/permissions/", parameters: nil, httpMethod: "DELETE")
      deletepermission?.start(completionHandler: {(connection,result,error)-> Void in
        let manager = FBSDKLoginManager()
        manager.logOut()
        print("the delete permission is (result)")
      })
      do {
        try Auth.auth().signOut()
        AppDelegate.sharedDelegate.moveToLoginRoom(index: 0)
      }
      catch let error {
        print(error.localizedDescription)
      }
    }
    controller.addAction(okay)
    self.present(controller, animated: true, completion: nil)
    
  }
  
  func dismissKeyboard() {
    //Causes the view (or one of its embedded text fields) to resign the first responder status.
    view.endEditing(true)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    pinText.text = nil
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  //code to only accept digits in textfield
  func textField(_ textField: UITextField,
                 shouldChangeCharactersIn range: NSRange,
                 replacementString string: String) -> Bool {
    
    let allowedCharacters = CharacterSet.decimalDigits
    let characterSet = CharacterSet(charactersIn: string)
    
    return allowedCharacters.isSuperset(of: characterSet)
    
  }
  
  @IBAction func actionStranger(_ sender: Any) {
    Group.singleton.isStrange = true
    ref.child("rooms").observeSingleEvent(of: .value, with: { snapshot in
      var allGroups = [String]()
      let enumerator = snapshot.children
      while let rest = enumerator.nextObject() as? DataSnapshot {
        if let curRoom = rest.childSnapshot(forPath: "roomPin").value as? String {
          if let isStrange = rest.childSnapshot(forPath: "isStrange").value as? Bool {
            if let isPlaying = rest.childSnapshot(forPath: "isPlaying").value as? Bool {
              var isFull = false
              var isReopen = false
              if let isFullGroup = rest.childSnapshot(forPath: "isFull").value as? Bool {
                isFull = isFullGroup
              }
              if let reOpen = rest.childSnapshot(forPath: "isReopen").value as? Bool {
                isReopen = reOpen
              }
              if (isStrange == true && isPlaying == false && isFull == false) {
                if isReopen {
                  allGroups.insert(curRoom, at: 0)
                } else {
                  allGroups.append(curRoom)
                }
              }
            }
          }
        }
      }
      //Create Group
      if allGroups.count > 0 {
        self.joinStrangeGroup(allGroups.first!)
      } else {
        self.createStrangeGroup()
      }
    })
    
    //      //error message
    //      let alert = UIAlertController(title: "Room doesn't exist", message: "Try creating a new room or re-typing your pin number", preferredStyle: .alert)
    //      alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
    //      self.present(alert, animated: true)
    //    })//Good
  }
  
  func joinStrangeGroup(_ curRoom: String) {
    let userId = Auth.auth().currentUser?.uid
    ref.child("rooms").child(curRoom).child("comments").child(userId!).removeValue()
    
    if let currentPlayer = getCurrentPlayer(){
      currentPlayer.joinGame(curPin: curRoom)
      DispatchQueue.main.async {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "EnterRoomViewController") as! EnterRoomViewController
        controller.curPin = curRoom
        self.navigationController?.pushViewController(controller, animated: true)
      }
      return
    }
  }
  
  func createStrangeGroup() {
    let pin = generatePIN() // where to generate Pin? in Player Class???
    self.curPin = pin!
    
    if let currentPlayer = getCurrentPlayer(){
      
      currentPlayer.createGame(curPin: self.curPin, isStrange: true)
      let controller = self.storyboard?.instantiateViewController(withIdentifier: "EnterRoomViewController") as! EnterRoomViewController
      controller.curPin = self.curPin
      self.navigationController?.pushViewController(controller, animated: true)
      //                performSegue(withIdentifier: "toroom1", sender: self)
      
    }
  }
  
  
  
  /*
   
   prepare for segue function, it should possibly not pass hardcoded data. By this I mean that it shouldn't get its from the database
   and from an external variable like curPin
   what we want to do is to make the usersNames append all current players in database
   
   
   */
  
  @IBAction func unwindSegueToMainVC(_ sender:UIStoryboardSegue) { }
}


