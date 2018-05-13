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

var ref:DatabaseReference! = Database.database().reference()

class ViewController: UIViewController, UITextFieldDelegate {
    var curPin:String = "0000"
    let gifManager = SwiftyGifManager(memoryLimit:10)
    @IBOutlet weak var scubaGif: UIImageView!

    
    @IBOutlet weak var pinText: UITextField!
    
    /***************************JOIN AND CREATE BUTTONS****************************/
   
    @IBAction func Join(_ sender: UIButton) {
      
        ref.child("rooms").observeSingleEvent(of: .value, with: { snapshot in
             // I got the expected number of items
            let enumerator = snapshot.children
            
            while let rest = enumerator.nextObject() as? DataSnapshot {
              if let curRoom = rest.childSnapshot(forPath: "roomPin").value as? String {
                if (self.pinText.text == curRoom) {
                  let userId = Auth.auth().currentUser?.uid
                  ref.child("rooms").child(self.pinText.text!).child("comments").child(userId!).removeValue()
                  
                  self.curPin = self.pinText.text!
                  
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
     
            if let currentPlayer = getCurrentPlayer(){
                
                currentPlayer.createGame(curPin: curPin)
              let controller = self.storyboard?.instantiateViewController(withIdentifier: "EnterRoomViewController") as! EnterRoomViewController
              controller.curPin = curPin
              self.navigationController?.pushViewController(controller, animated: true)
//                performSegue(withIdentifier: "toroom1", sender: self)
              
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
      let gif = UIImage(gifName: "scuba-pama-large")
      scubaGif.setGifImage(gif, manager: gifManager, loopCount: -1)
      
      
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
    
    /*
 
    prepare for segue function, it should possibly not pass hardcoded data. By this I mean that it shouldn't get its from the database
    and from an external variable like curPin
    what we want to do is to make the usersNames append all current players in database
     
 
    */
  
  func sendInvites() {
    let id = "id1277137775"
    if let name = NSURL(string: "https://itunes.apple.com/us/app/myapp/\(id)?ls=1&mt=8") {
      let textToShare = "Hey, Lets play onlne caption game. Download application"
      let objectsToShare = [name,textToShare] as [Any]
      let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
      
      self.present(activityVC, animated: true, completion: nil)
    }
    else
    {
      // show alert for not available
      showAlert(message: "Application not available")
    }
  }

  @IBAction func actionInviteFriend(_ sender: UIButton) {
        sendInvites()
  }
  
    @IBAction func unwindSegueToMainVC(_ sender:UIStoryboardSegue) { }
}


