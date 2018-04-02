//
//  CaptioningVC.swift
//  CaptionIt
//
//  Created by Nicolas Lopez on 3/28/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import Foundation
import FirebaseDatabase
import UIKit

class CaptioningVC: UIViewController,UITextFieldDelegate {
    @IBOutlet weak var meme: UIImageView!
    @IBOutlet weak var myTextView: UILabel!
    @IBOutlet weak var myTextField: UITextField!
    var curPin: String?
    var hasCurrentJudge:Bool?
    var currentJudge: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myTextField.delegate = self
        setJudge()
        /* SET JUDGE TAKES TO LONG TO UPDATE VALUES AND THAT WHY THE NEXT CONDITION DOESNT WORK*/
        if currentJudge != nil{
            print("abra cadabra")
            ref.child("rooms").child(curPin!).child("players").child(currentJudge!).observeSingleEvent(of: .value, with: { snapshot in
            let currentPlayer = snapshot.children
            
            let isJudge = currentPlayer.value(forKeyPath: "judge") as? Bool
            if isJudge == true  {
                self.performSegue(withIdentifier: "waitingRoomSegue", sender: Any?.self)
            }
        })
        }

        
        //        var inputText = myTextField.text
        //        myTextView.text = inputText
        
    }
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            myTextView.text = updatedText
        }
        return true
    }
    func setJudge(){
        
        ref.child("rooms").child(curPin!).child("players").observeSingleEvent(of: .value, with: { snapshot in
            // I got the expected number of items
            let allPlayers = snapshot.children
            print("hello")
            if let players  = allPlayers.allObjects as? [DataSnapshot]{
                
                for player in players{
                    var username = player.key as? String
                    var value = player.value as! [String : Any]
                    var hasBeenJudge = value["hasBeenJudge"] as? Bool
                    if hasBeenJudge == false {
                        ref.child("rooms").child(self.curPin!).child("players").child(username!).updateChildValues(["judge":  true])
                        let hasNewJudge = value["judge"] as? Bool
                        self.hasCurrentJudge = hasNewJudge
                        self.currentJudge = username
                        print("Holo")
//
//                        var notjudge: Bool = false {
//                            didSet {
//                                if notjudge != value["judge"] as? Bool {
//                                    self.performSegue(withIdentifier: "gameIsOn!", sender: Any?.self)
//                                    print("moreInside")
//                                }
//                            }
//                        }
                    }
                }
                
                
            }
            
        })

    }
    
   
}

