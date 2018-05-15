//
//  SettingsController.swift
//  CaptionIt
//
//  Created by Nicolas Lopez on 4/12/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseDatabase
import SwiftyGif



class SettingsController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var mummyGif: UIImageView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    var ref:DatabaseReference! = Database.database().reference()
    
    override func viewDidLoad() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
//        mummyGif.image = UIImage.gifImageWithName(name: "mummy")
      let gifManager = SwiftyGifManager(memoryLimit:10)
      let gif = UIImage(gifName: "mummy (1)")
      mummyGif.setGifImage(gif, manager: gifManager, loopCount: 1)
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    @IBAction func submitPassword(_ sender: UIButton) {
        if let passwordText = passwordField.text{
        Auth.auth().currentUser?.updatePassword(to: passwordText) { (error) in
            if(error == nil){
                let alert = UIAlertController(title: "Your password has been reset", message: "Now keep on playing with your friends", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Understood", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            else{
                let alert = UIAlertController(title: "Invalid password", message: "Please enter a valid password to change your credentials", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Understood", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
        }
        }
    }
    
    @IBAction func submitEmail(_ sender: UIButton) {
        if let emailText = emailField.text{
        Auth.auth().currentUser?.updateEmail(to: emailText) { (error) in
            if(error == nil){
            let alert = UIAlertController(title: "Your email has been reset", message: "Now keep on playing with your friends", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Understood", style: .cancel, handler: nil))
            self.present(alert, animated: true)
            }
            else{
                let alert = UIAlertController(title: "Invalid email address", message: "Please enter a valid email address to change your email credentials", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Understood", style: .cancel, handler: nil))
                self.present(alert, animated: true)
            }
            }
            
        }
        
    }
  
    
    @IBAction func submitUsername(_ sender: UIButton) {
    
        if let usernameText = usernameField.text{
        ref.child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(["username": usernameText])
        let alert = UIAlertController(title: "Your username has been reset", message: "Now keep on playing with your friends", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Understood", style: .cancel, handler: nil))
        self.present(alert, animated: true)
        }
    }
     
    @IBAction func logoutButtonTapped(_ sender: Any) {
      let controller = UIAlertController(title: "Wait!", message: "Are you sure you want to Logout?", preferredStyle: .alert)
      let leave = UIAlertAction(title: "Logout", style: .default) { (action) in
        do {
          try Auth.auth().signOut()
          AppDelegate.sharedDelegate.moveToLoginRoom(index: 0)
        }
        catch let error {
          print(error.localizedDescription)
        }
      }
      let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      controller.addAction(leave)
      controller.addAction(cancel)
      self.present(controller, animated: true, completion: nil)
      
    }

    
}
