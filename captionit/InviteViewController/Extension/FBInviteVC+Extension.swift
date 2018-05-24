//
//  FBInviteVC+Extension.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 24/05/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import Foundation
import UIKit

extension FBInviteViewController: UITableViewDelegate, UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return listFriends.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "InviteCell") as! InviteCell
    let friendDetail = listFriends[indexPath.row] as! [String: Any]
    if let name = friendDetail["username"] as? String {
      cell.lblName.text = name
    } else {
        cell.lblName.text = "Undefined"
    }
    return cell
  }
}
