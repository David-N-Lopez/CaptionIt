//
//  JudgementVC.swift
//  CaptionIt
//
//  Created by veera jain on 03/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit

class JudgementVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
  
    var players = [Player]()
    
    @IBOutlet weak var captionTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captionTableView.dataSource = self
        captionTableView.delegate = self
        captionTableView.estimatedRowHeight = 300
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: ACTIONS
    
   @objc func rewardPlayerAction(_ sender:UIButton)  {
        sender.setImage(#imageLiteral(resourceName: "Yello"), for: .normal)
    
    // perform further actions
    
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return players.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let captionCell = captionTableView.dequeueReusableCell(withIdentifier: "captionCell", for: indexPath) as! CaptionCell
        // image
        // caption
        captionCell.btnReward.addTarget(self, action: #selector(self.rewardPlayerAction(_:)), for: .touchUpInside)
        return captionCell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
}
