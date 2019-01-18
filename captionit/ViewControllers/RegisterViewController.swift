//
//  RegisterViewController.swift
//  CaptionIt
//
//  Created by KMSOFT on 03/02/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit

enum registerControllerType {
  case register
  case Facebook
}

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var closeButtton: UIButton!
  var type:registerControllerType = .register
  @IBOutlet weak var viewFaceBook: UIView!
  @IBOutlet weak var textFBName: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
      if type == . Facebook {
        viewFaceBook.isHidden = false
      }
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
      if self.navigationController?.childViewControllers.count == 1 {
        btnBack.isHidden = true
      }
        // Do any additional setup after loading the view.
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Button Tap Event
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        if(self.usernameTextField.text == "") {
            self.showAlert(message: "Please enter username")
        } else if(self.emailTextField.text == "") {
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
            Users.registerUser(username: usernameTextField.text!, email: emailTextField.text!, password: passwordTextField.text!, callback: { (success, user, error) in
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
    
    
  @IBAction func actionUpdateUserName(_ sender: Any) {
    if(self.textFBName.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "") {
      self.showAlert(message: "Please enter username")
    } else {
      self.showProgressHUD()
      Users.updateUserName(userName: self.textFBName.text!, callback: { (success, error) in
        self.dismissProgressHUD()
        if success {
          if let id = getUserId() {
            ref.child("Users").child(id).child("token").setValue(Group.singleton.token)
          }
          AppDelegate.sharedDelegate.moveToEnterRoom(index: 0)
        } else {
          if let err = error {
           self.showAlert(message: err.localizedDescription)
          }
        }
      })
    }
  }
  /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
