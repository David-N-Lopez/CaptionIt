//
//  LoginViewController.swift
//  CaptionIt
//
//  Created by KMSOFT on 03/02/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var closeButtton: UIButton!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
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
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    self.showAlert(message: error!.localizedDescription)
                }
            })
        }
    }
    
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.present(viewController, animated: true, completion: nil)
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

