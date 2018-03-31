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

var ref:DatabaseReference! = Database.database().reference()

class ViewController: UIViewController, UITextFieldDelegate {
    var curPin:String = "0000"
    
    @IBOutlet weak var pinText: UITextField!
    
    /***************************JOIN AND CREATE BUTTONS****************************/
   
    @IBAction func Join(_ sender: UIButton) {

        ref.child("rooms").observeSingleEvent(of: .value, with: { snapshot in
             // I got the expected number of items
            let enumerator = snapshot.children
            
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let curRoom = rest.childSnapshot(forPath: "roomPin").value as! String
                
                
                if (self.pinText.text == curRoom) {
                    print("Booyah")
                    self.curPin = self.pinText.text!
                    
                    if let currentPlayer = getCurrentPlayer(){
                        currentPlayer.joinGame(curPin: curRoom)
                        self.performSegue(withIdentifier: "toroom1", sender: self)
                    }
                    
                }
            }
        })//Good


    }
    /*******************create game makes reference to the player function createGame******************/
    
    @IBAction func CreateGame(_ sender: UIButton) {
        let pin = generatePIN() // where to generate Pin? in Player Class???
        curPin = pin!
     
            if let currentPlayer = getCurrentPlayer(){
                
                currentPlayer.createGame(curPin: curPin)
                performSegue(withIdentifier: "toroom1", sender: self)
                
                }
    }
    /*
     
     The segue toroom1 passes the current pin (curPin) and the current player username through the
     prepare for segue function
 
     */
    
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            self.present(viewController, animated: true, completion: nil)
        }
        catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pinText.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(Auth.auth().currentUser == nil) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                let viewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(viewController, animated: true, completion: nil)
            })
        }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toroom1" {
            let controller = segue.destination as! EnterRoomViewController
            controller.curPin = curPin
        }
    }
  
    @IBAction func unwindSegueToMainVC(_ sender:UIStoryboardSegue) { }
}


