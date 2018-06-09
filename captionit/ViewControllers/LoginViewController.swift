//
//  LoginViewController.swift
//  CaptionIt
//
//  Created by KMSOFT on 03/02/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import FirebaseAuth
import SwiftyGif
import FacebookCore
import FacebookLogin
import FBSDKLoginKit
import SVProgressHUD



class LoginViewController: UIViewController {
    
    @IBOutlet weak var closeButtton: UIButton!
    @IBOutlet weak var blinkingGif: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
  @IBOutlet weak var btnSignup: UIButton!
  @IBOutlet weak var btnSignIn: UIButton!
  @IBOutlet weak var viewSignUp: UIView!
  @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
//        blinkingGif.image = UIImage.gifImageWithName(name: "blinking-pama")
      let gifManager = SwiftyGifManager(memoryLimit:10)
      let gif = UIImage(gifName: "blinking-pama-correct")
      blinkingGif.setGifImage(gif, manager: gifManager, loopCount: -1)
        // Do any additional setup after loading the view.
        
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(Auth.auth().currentUser != nil) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Tap Event
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        if(self.emailTextField.text == "") {
            self.showAlert(message: "Please enter email")
        }
        else if (!Utility.isValidEmail(email: self.emailTextField.text!)) {
            self.showAlert(message: "Please enter valid email")
        }
        else if(self.passwordTextField.text == "") {
            self.showAlert(message: "Please enter password")
        }
        else {
            self.showProgressHUD()
            Users.loginUser(email: emailTextField.text!, password: passwordTextField.text!, callback: { (success, user, error) in
                self.dismissProgressHUD()
                if(success) {
                  if let id = getUserId() {
                    ref.child("Users").child(id).child("token").setValue(Group.singleton.token)
                  }
                  AppDelegate.sharedDelegate.moveToEnterRoom(index: 0)
                }
                else {
                    self.showAlert(message: error!.localizedDescription)
                }
            })
        }
    }
    
  func resetButton() {
    btnSignup.isSelected = false
    btnSignIn.isSelected = false
    btnSignIn.titleLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 17)
    btnSignup.titleLabel?.font = UIFont(name: "SourceSansPro-Regular", size: 17)

  }
  
    @IBAction func registerButtonTapped(_ sender: UIButton) {
      if sender.isSelected {
        return
      }
      resetButton()
      sender.isSelected = false
      sender.titleLabel?.font = UIFont(name: "SourceCodePro-Bold", size: 17)
      if sender.tag == 1 {
        viewSignUp.alpha = 0
        viewSignUp.isHidden = false
        UIView.animate(withDuration: 0.4, animations: {
          self.viewSignUp.alpha = 1
        })
      } else {
        viewSignUp.alpha = 1

        UIView.animate(withDuration: 0.4, animations: {
          self.viewSignUp.alpha = 0
        }, completion: { (success) in
          self.viewSignUp.isHidden = true
        })
      }
    }
  
  
  @IBAction func actionFaceBookLogin(_ sender: UIButton) {
    let fbLoginManager = FBSDKLoginManager()
    
    fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
      if let error = error {
        print("Failed to login: \(error.localizedDescription)")
        return
      }
      
      guard let accessToken = FBSDKAccessToken.current() else {
        print("Failed to get access token")
        return
      }
      
      
      if let res = result {
        if res.isCancelled {
          print("Login Cancelled")
          return
        }
      } else {
        return
      }
      
      let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
      
      // Perform login by calling Firebase APIs
      self.showProgressHUD()
      Auth.auth().signIn(with: credential, completion: { (user, error) in
        self.dismissProgressHUD()
        if let error = error {
          print("Login error: \(error.localizedDescription)")
          let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
          let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
          alertController.addAction(okayAction)
          self.present(alertController, animated: true, completion: nil)
          return
        }
        
        // Present the main view
        if let id = getUserId() {
          self.getFBUserData()
          ref.child("Users").child(id).child("token").setValue(Group.singleton.token)
          ref.child("Users").child(id).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.value as? String) != nil {
              AppDelegate.sharedDelegate.moveToEnterRoom(index: 0)
            } else {
              let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
              viewController.type = .Facebook
              self.present(viewController, animated: true, completion: nil)
            }
          })
        }
        
      })
      
    }
  }
  
  //function is fetching the user data
  func getFBUserData() {
    if(AccessToken.current != nil){
      FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id"]).start(completionHandler: { (connection, result, error) -> Void in
        if (error == nil){
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
  
  
  @IBAction func actionEmailLogin(_ sender: UIButton) {
    let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
    viewController.type = .register
    self.present(viewController, animated: true, completion: nil)
  }
  
    @IBAction func unwindSegueToLogin(_ sender:UIStoryboardSegue) { }

    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

