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

class CaptioningVC: UIViewController, UITextViewDelegate{
  @IBOutlet weak var lblTimer: UILabel!
  @IBOutlet weak var meme: UIImageView!
  @IBOutlet weak var myTextField: UITextView!
  @IBOutlet weak var btnUpload: UIButton!
  var curPin: String?
  var hasCurrentJudge:Bool?
  var currentJudge: String?
  var judgeID:String?
  var judgeId = String()
  var memeImageUrl : String?
  var mediaType = 1
  var player : AVPlayer?
  var round = 0
  var totalUser = 0
  var isJudge = false
  var playerLayer : AVPlayerLayer?
  var gameTimer: Timer!
  var totalTime = 120
  
  override func viewDidLoad() {
    super.viewDidLoad()
    Group.singleton.observeAnyoneLeftGame(curPin!)
    myTextField.delegate = self
    myTextField.text = "CaptionIt!"
    myTextField.textColor = UIColor.lightGray
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
    view.addGestureRecognizer(tap)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    myTextField.text = nil
    setJudge()
    Group.singleton.startTime()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.alertErroOccured(_ :)),
      name: NSNotification.Name(rawValue: errorOccured),
      object: nil)
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.userTimerExpired),
      name: NSNotification.Name(rawValue: timerExpired),
      object: nil)
  }
  
  func textViewDidBeginEditing(_ textView: UITextView) {
        
        if myTextField.textColor == UIColor.lightGray {
            myTextField.text = ""
            myTextField.textColor = UIColor.black
        }
    }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if myTextField.text.count > 0 {
      btnUpload.isEnabled = true
      btnUpload.alpha = 1
    } else {
      btnUpload.isEnabled = false
      btnUpload.alpha = 0.5
    }
    return true
  }
  
  func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

  func setJudge(){
    ref.child("rooms").child(curPin!).child("players").observeSingleEvent(of: .value, with: { snapshot in
      // I got the expected number of items
      let allPlayers = snapshot.children
      print("hello")
      if let players  = allPlayers.allObjects as? [DataSnapshot]{
        self.totalUser = players.count
        Group.singleton.totalUser = self.totalUser
        Group.singleton.round += 1
        for player in players{
          let username = player.key
          var value = player.value as! [String : Any]
          let udid = value["ID"] as! String
          let hasBeenJudge = value["hasBeenJudge"] as? Bool
          let meme = value["memeURL"] as! String
          if let type = value["mediaType"] as? Int {
            self.mediaType = type
          }
          if hasBeenJudge == false {
            self.memeImageUrl = meme
           Group.singleton.judgeID = udid
            ref.child("rooms").child(self.curPin!).child("players").child(username).updateChildValues(["judge":  true])
            self.hasCurrentJudge = hasBeenJudge
            self.currentJudge = username
            self.judgeID = udid
            if Auth.auth().currentUser?.uid == udid {
             self.isJudge = true
              DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
                Group.singleton.stopTimer()
                let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "WaitingViewController") as! WaitingViewController
                destinationVC.groupId = self.curPin!
                destinationVC.judgeID = self.judgeID!
                destinationVC.memeURL = self.memeImageUrl!
                destinationVC.judgeName = self.currentJudge!
                destinationVC.mediaType = self.mediaType
                destinationVC.round = self.round
                destinationVC.totalUser = self.totalUser
                self.navigationController?.pushViewController(destinationVC, animated: true)
              }
            } else {
              self.startTimer()
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
          Group.singleton.stopTimer()
          let controller = self.storyboard?.instantiateViewController(withIdentifier: "ResultVC") as! ResultVC
          controller.curPin = self.curPin!
          self.navigationController?.pushViewController(controller, animated: true)
        }
        
        
      }
      
    })
    
  }
  
  func userTimerExpired()  {
    let controller = UIAlertController(title: "Error", message: "Something went wrong", preferredStyle: .alert)
    let leave = UIAlertAction(title: "Okay", style: .default) { (action) in
      self.navigationController?.popToRootViewController(animated: true)
    }
    controller.addAction(leave)
    self.present(controller, animated: true, completion: nil)
  }
  
    private func playVideo(from url:URL){
    player = AVPlayer(url: url)
    SVProgressHUD.show()
    playerLayer = AVPlayerLayer(player: player)
//      playerLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
      playerLayer?.frame = self.meme.frame
      self.view.layer.addSublayer(playerLayer!)
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
   
   Group.singleton.stopTimer()
    ref.child("rooms").child(self.curPin!).child("comments").child(self.judgeID!).child(currentUser!).setValue(myTextField.text) { (error, reff) in
      if error == nil {
        let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "JudgementVC") as! JudgementVC
        destinationVC.groupId = self.curPin!
        destinationVC.judgeID = self.judgeID!
        destinationVC.memeURL = self.memeImageUrl!
        destinationVC.judgeName = self.currentJudge!
        destinationVC.mediaType = self.mediaType
        destinationVC.round = self.round
        destinationVC.totalUser = self.totalUser
        self.navigationController?.pushViewController(destinationVC, animated: true)
      }
    }
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    if gameTimer != nil {
      gameTimer.invalidate()
      gameTimer = nil
    }
    if self.isJudge == false {
      player?.currentItem!.removeObserver(self, forKeyPath: "status")
    }
    NotificationCenter.default.removeObserver(self)
    if playerLayer != nil {
      playerLayer?.removeFromSuperlayer()
    }
  }
  //leaveCaptioningSegue
  @IBAction func actionLeaveGame(_ sender : Any) {
    let controller = UIAlertController(title: "The game is still in progress!", message: "Are you sure you want to leave? if you leave, your friends will no longer be able to keep on playing", preferredStyle: .alert)
    let leave = UIAlertAction(title: "Leave", style: .default) { (action) in
      Group.singleton.removeErrorObservers()
      let currentUser = Auth.auth().currentUser?.uid
  ref.child("rooms").child(self.curPin!).child("players").child(currentUser!).removeValue()
      self.navigationController?.popToRootViewController(animated: true)
    }
    let cancel = UIAlertAction(title: "Stay", style: .cancel, handler: nil)
    controller.addAction(leave)
    controller.addAction(cancel)
    self.present(controller, animated: true, completion: nil)
  }
  
  func alertErroOccured(_ notification: NSNotification) {
    if let wasJudge = notification.userInfo?["isJudge"] as? Bool {
      // do something with your image
      if Group.singleton.totalUser <= 1 {
        let controller = UIAlertController(title: "Error: Something went wrong", message: "All of your friends unexpectedly left the game.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
          Group.singleton.removeErrorObservers()
          Group.singleton.deleteMediaForGroup()
          self.navigationController?.popToRootViewController(animated: true)
        }
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
        return
      }
      if wasJudge {
        if self.gameTimer != nil {
          self.gameTimer.invalidate()
          self.gameTimer = nil
        }
        let controller = UIAlertController(title: "Error: Something went wrong", message: "Judge Left the game", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
          self.meme.image = nil;
          self.setJudge()
        }
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
      }
    }
  }
  
  func startTimer() {
    totalTime = 120
    gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
  }
  
  func runTimedCode() {
    if totalTime <= 0 {
      lblTimer.text = Group.singleton.timeFormatted(totalTime)
      myTextField.text = "I wasn't feeling creative"
      gameTimer.invalidate()
      gameTimer = nil
      uploadComment()
    } else {
      totalTime -= 1
      lblTimer.text = Group.singleton.timeFormatted(totalTime)
    }
  }
}

