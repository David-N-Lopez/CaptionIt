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
    if selectedIndex.contains(indexPath.row) {
      cell.imageSelected.isHidden = false
    } else {
      cell.imageSelected.isHidden = true
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! InviteCell
    if selectedIndex.contains(indexPath.row) {
      cell.imageSelected.isHidden = true
      if let index = selectedIndex.index(of: indexPath.row) {
      selectedIndex.remove(at: index)
      }
    } else {
      cell.imageSelected.isHidden = false
      selectedIndex.append(indexPath.row)
    }
    if selectedIndex.count > 0 {
      btnInvite.isEnabled = true
      btnInvite.alpha = 1
    } else {
      btnInvite.isEnabled = false
      btnInvite.alpha = 0.5
    }
  }
}
