//
//  resetPasswordVC.swift
//  CaptionIt
//
//  Created by Nicolas Lopez on 4/10/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import FirebaseAuth
import UIKit
class resetPasswordVC: UIViewController {
     @IBOutlet weak var resetEmail: UITextField!

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
    @IBAction func resetPassword (_ sender: Any){
        if let rstEmail = resetEmail.text{
            Auth.auth().sendPasswordReset(withEmail: rstEmail) { (error) in
                if(error == nil){
                    let alert = UIAlertController(title: "Check your email ", message: "we sent you an email to update your password!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Understood", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
                else{
                    let alert = UIAlertController(title: "Invalid email", message: "Please enter a valid email to update your password", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Understood", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
}
