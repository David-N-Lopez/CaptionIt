//
//  InviteViewController.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 17/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit

class InviteViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  @IBAction func actionShareInvite(_ sender: Any) {
    sendInvites()
  }
  
  @IBAction func actionBack(_ sender: Any) {
      self.navigationController?.popViewController(animated: true)
  }
  
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


}
