//
//  InviteViewController.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 17/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit

class InviteViewController: UIViewController {
let array = [#imageLiteral(resourceName: "bee-pama"),#imageLiteral(resourceName: "cat-pama"),#imageLiteral(resourceName: "NYE-pama"),#imageLiteral(resourceName: "pirate-pama"),#imageLiteral(resourceName: "snow-pama"),#imageLiteral(resourceName: "st-pats-pama(1)")]
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func actionShareInvite(_ sender: Any) {
    
  }
  
  @IBAction func actionBack(_ sender: Any) {
      self.navigationController?.popViewController(animated: true)
  }
  
  


}
