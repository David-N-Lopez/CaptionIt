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

class CaptioningVC: ViewController{
    @IBOutlet weak var meme: UIImageView!
    @IBOutlet weak var myTextView: UILabel!
    @IBOutlet weak var myTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myTextField.delegate = self
        var inputText = myTextField.text
        myTextView.text = inputText
        
    }
}
