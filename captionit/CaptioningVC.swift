//
//  CaptioningVC.swift
//  CaptionIt
//
//  Created by Nicolas Lopez on 3/28/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import UIKit
import AVKit
import SDWebImage
import SVProgressHUD

class CaptioningVC: UIViewController,UITextFieldDelegate {
  @IBOutlet weak var meme: UIImageView!
  @IBOutlet weak var myTextView: UILabel!
  @IBOutlet weak var myTextField: UITextField!
  var curPin: String?
  var hasCurrentJudge:Bool?
  var currentJudge: String?
  var judgeID : String?
  var memeImageUrl : String?
  var mediaType = 1
  var player : AVPlayer?
  var round = 0
  var totalUser = 0
  override func viewDidLoad() {
    super.viewDidLoad()
    self.myTextField.delegate = self
    setJudge()
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
    view.addGestureRecognizer(tap)
  }
  
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
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
        self.totalUser = players.count
        for player in players{
          let username = player.key
          var value = player.value as! [String : Any]
          let udid = value["ID"] as! String
          let hasBeenJudge = value["hasBeenJudge"] as? Bool
          let meme = value["memeURL"] as! String
          self.round += 1
          if let type = value["mediaType"] as? Int {
            self.mediaType = type
          }
          if hasBeenJudge == false {
            self.memeImageUrl = meme
            ref.child("rooms").child(self.curPin!).child("players").child(username).updateChildValues(["judge":  true])
            self.hasCurrentJudge = hasBeenJudge
            self.currentJudge = username
            self.judgeID = udid
            if Auth.auth().currentUser?.uid == udid {
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
                self.performSegue(withIdentifier: "waitingRoomSegue", sender: self)
              }
            } else {
              if self.mediaType == 1 {
              self.meme.sd_setImage(with: URL(string:meme), placeholderImage: nil, options: .scaleDownLargeImages, completed: nil)
              } else {
                self.playVideo(from: URL(string:meme)!)
              }
            }
            
            return
          }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // change 2 to desired number of seconds
          self.performSegue(withIdentifier: "Game_Over", sender: self)
        }
        
        
      }
      
    })
    
  }
  
  private func playVideo(from url:URL) {
    
    player = AVPlayer(url: url)
    SVProgressHUD.show()
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    playerLayer.frame = self.meme.frame
    self.view.layer.addSublayer(playerLayer)
    player?.play()
    NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
    player?.currentItem!.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions(), context: nil)
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if player?.currentItem?.status == AVPlayerItemStatus.readyToPlay {
      SVProgressHUD.dismiss()
      self.player!.play()
    }
  }
  
  @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
    if self.player != nil {
      self.player!.seek(to: kCMTimeZero)
      self.player!.play()
    }
  }
  
  @IBAction func actionUploadComment(_ sender : Any) {
    if myTextField.text!.count > 0 {
      uploadComment()
    }
  }
  
  func uploadComment() {
    let currentUser = Auth.auth().currentUser?.uid
    ref.child("rooms").child(self.curPin!).child("comments").child(self.judgeID!).child(currentUser!).setValue(myTextField.text) { (error, reff) in
      if error == nil {
        self.performSegue(withIdentifier: "judgement_segue", sender: self)
      }
    }
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    player?.currentItem!.removeObserver(self, forKeyPath: "status")
    NotificationCenter.default.removeObserver(self)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "judgement_segue" {
      if let destinationVC = segue.destination as? JudgementVC {
        destinationVC.groupId = self.curPin!
        destinationVC.judgeID = self.judgeID!
        destinationVC.memeURL = memeImageUrl!
        destinationVC.judgeName = currentJudge!
        destinationVC.mediaType = mediaType
        destinationVC.round = round
        destinationVC.totalUser = totalUser
      }
    } else if segue.identifier == "waitingRoomSegue" {
      if let destinationVC = segue.destination as? WaitingViewController {
        destinationVC.groupId = self.curPin!
        destinationVC.judgeID = self.judgeID!
        destinationVC.memeURL = memeImageUrl!
        destinationVC.judgeName = currentJudge!
        destinationVC.mediaType = mediaType
        destinationVC.round = round
        destinationVC.totalUser = totalUser
      }
    } else if segue.identifier == "Game_Over" {
      if let destinationVC = segue.destination as? ResultVC {
        destinationVC.curPin = self.curPin!
      }
    }
    
  }
  
}

