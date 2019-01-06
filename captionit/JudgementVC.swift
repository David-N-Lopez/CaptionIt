//
//  JudgementVC.swift
//  CaptionIt
//
//  Created by veera jain on 03/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SDWebImage
import FirebaseAuth
import AVKit
import Photos
import SVProgressHUD

class JudgementVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
  @IBOutlet weak var btnNext: UIButton!
  @IBOutlet weak var btnPrevious: UIButton!
  @IBOutlet weak var viewSingleImage: UIView!
  @IBOutlet weak var imageCaption: UIImageView!
  @IBOutlet weak var viewVideo: UIView!
  @IBOutlet weak var viewWaiting: UIView!
  @IBOutlet weak var saveMediaView: DesignableView!
  @IBOutlet weak var btnWinnerPrev: UIButton!
  @IBOutlet weak var btnWinnerNext: UIButton!
  
  var usersComments = [Any]()
  var groupId = String()
  var judgeID = String()
  var judgeName = String()
  var strJudgeName = String()
  var memeURL = String()
  var mediaType = 1
  var player: AVPlayer?
  var hasBeenJudgeRef: DatabaseReference?
  var winnerRef: DatabaseReference?
  var readyNextRoundRef: DatabaseReference?
  var round = 0
  var totalUser = 0
  var currentCommentIndex = 0
  var gameWinnerID = ""
  let currentUserId = Auth.auth().currentUser?.uid
  var mediaData: Data?
  var videoSaved: String?
  var oncePlayed = Bool()
  var playersReady = 0
    
 let glimpse = Glimpse()
    var saveClicked = Bool()
    
  // Judge
  @IBOutlet weak var imageJudge: UIImageView!
  @IBOutlet weak var viewJudge: UIView!
  @IBOutlet weak var captionTableView: UITableView!
  @IBOutlet weak var textJudgeName: UILabel!
  @IBOutlet weak var textReadyUsers: UILabel!
  @IBOutlet weak var textRound: UILabel!
  @IBOutlet weak var textSingleComment: UILabel!
  
  //Winner
  @IBOutlet weak var viewWinnerName: UIView!
  @IBOutlet weak var textWinnerName: UILabel!
  @IBOutlet weak var viewWinnerButtons: UIView!
  @IBOutlet weak var btnNextRounds: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    totalUser = Group.singleton.totalUser
    round = Group.singleton.round
    saveClicked = false
    oncePlayed = false
    Group.singleton.startTime()
    if mediaType == 2 {
      saveVideoToPath(memeURL, completion: { (success, filePath) in
        self.videoSaved = filePath
      })
    }
    hasBeenJudgeRef = ref.child("rooms").child(groupId).child("players").child(judgeName).child("hasBeenJudge")
    winnerRef = ref.child("rooms").child(groupId).child("comments").child(judgeName).child("winner")
    readyNextRoundRef = ref.child("rooms").child(groupId).child("readyPlayers")
//    readyNextRoundRef?.child(currentUserId!).setValue(false)
    getUserName(judgeID, "Default user") { (name) in
      self.strJudgeName = name
      if Auth.auth().currentUser?.uid == self.judgeID {
        self.textRound.text = "ROOM #\(self.groupId)"
        self.textJudgeName.text = "Pick your favorite CAPTION!"
      } else {
        self.textJudgeName.text = "\(name) is the judge!"
      }
    }
    getAllComments()
    updateMemeMedia()
    updateNumberOfUsersCommented()
    self.textRound.text = "Round \(round)"
    captionTableView.dataSource = self
    captionTableView.delegate = self
    captionTableView.estimatedRowHeight = 300
    captionTableView.tableFooterView = UIView()
    if self.judgeID == Auth.auth().currentUser?.uid {
      viewSingleImage.isHidden = false
    }
    if totalUser <= round {
      btnNextRounds.setTitle("Score Board", for: .normal)
    }
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
    
    let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left]
    for direction in directions {
      let gesture = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
      gesture.direction = direction
      self.viewSingleImage.addGestureRecognizer(gesture)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillAppear(_ animated: Bool) {
    observerGameFinish()
    observerWinnerOfGame()
    oberverAllPlayersReady()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    self.viewWaiting.frame = self.view.bounds
    self.view.addSubview(self.viewWaiting)
    self.viewWaiting.isHidden = true
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    player?.pause()
    NotificationCenter.default.removeObserver(self)
    hasBeenJudgeRef?.removeAllObservers()
    winnerRef?.removeAllObservers()
    readyNextRoundRef?.removeAllObservers()
  }
  
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
    if let swipeGesture = gesture as? UISwipeGestureRecognizer {
      switch swipeGesture.direction {
      case UISwipeGestureRecognizer.Direction.right:
        //Move previous Image
        print("Swiped right")
        self.previousImage(UIButton())
      
      case UISwipeGestureRecognizer.Direction.left:
        //Move next Image
        print("Swiped left")
        self.nextImage(UIButton())
      
      default:
        break
      }
    }
  }
  
  
    @objc func userTimerExpired()  {
    let controller = UIAlertController(title: "Error", message: "Something went wrong", preferredStyle: .alert)
    let leave = UIAlertAction(title: "Okay", style: .default) { (action) in
      self.navigationController?.popToRootViewController(animated: true)
    }
    controller.addAction(leave)
    self.present(controller, animated: true, completion: nil)
  }
  
  func getAllComments()  {
    ref.child("rooms").child(self.groupId).child("comments").child(self.judgeID).observe(.value, with: { (snapshot) in
      if let comment = snapshot.value as? [String: Any] {
        let allKeys = (comment as NSDictionary).allKeys
        self.usersComments.removeAll()
        for key in allKeys {
            let userId = key as! String
          if userId != "winner" {
            let user = ["id" : key,
                        "comment" : comment[userId]]
            self.usersComments.append(user)
          }
        }
        if self.usersComments.count <= 1 {
          self.btnNext.isEnabled = false
          self.btnNext.alpha = 0.5
          self.btnWinnerNext.isEnabled = false
          self.btnWinnerNext.alpha = 0.5
        } else {
          self.btnNext.isEnabled = true
          self.btnNext.alpha = 1
          self.btnWinnerNext.isEnabled = true
          self.btnWinnerNext.alpha = 1
        }
        if self.currentCommentIndex == 0 && Auth.auth().currentUser?.uid == self.judgeID && self.gameWinnerID.count == 0 {
          let comment = self.usersComments[0] as! [String : Any]
          self.textSingleComment.text = comment["comment"] as? String
          if self.usersComments.count == 1 {
            self.btnNext.alpha = 0.5
            self.btnNext.isEnabled = false
            self.btnWinnerNext.alpha = 0.5
            self.btnWinnerNext.isEnabled = false
          }
        }
        if Group.singleton.totalUser - 1 == self.usersComments.count && self.gameWinnerID.count == 0 {
          Group.singleton.stopTimer()
          Group.singleton.startTime()
          var id = self.getUserID(0)
          if id == self.judgeID {
            id = self.getUserID(1)
          }
          if id == getUserId() {
            Group.singleton.sendNotificationToJudge(self.judgeID, Constant.selectCaption)
          }
          self.textReadyUsers.text = "Wait for \(self.strJudgeName) to determine the funniest caption!"
        } else {
          self.updateNumberOfUsersCommented()
        }
        self.captionTableView.reloadData()
      }
      
    })
  }
  
  func getUserID(_ at: Int) -> String {
    let userDic = self.usersComments[0] as? [String: Any]
    let id = userDic!["id"] as? String
    return id!
  }
  
  func updateMemeMedia() {
    if mediaType == 1 {
      viewVideo.isHidden = true
      if Auth.auth().currentUser?.uid == self.judgeID || gameWinnerID.count > 0 {
      
        imageJudge.sd_setImage(with: URL(string:self.memeURL), placeholderImage: nil, options: .scaleDownLargeImages, completed: nil)
      } else {
      imageCaption.sd_setImage(with: URL(string:self.memeURL), placeholderImage: nil, options: .scaleDownLargeImages, completed: nil)
      }
    } else {
      viewVideo.isHidden = false
      self.playVideo(url: URL(string:self.memeURL)!)
      player?.play()
      if player != nil {
        player!.seek(to: CMTime.zero)
        player?.play()
      }
      NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:player!.currentItem , queue:nil , using: { (_ notification: Notification) in
        self.oncePlayed = true
        if self.saveClicked == true{
            self.saveClicked = false
//             print("video ends here")
//             self.glimpse.stop()
        }
        if self.player != nil {
            self.player!.seek(to: CMTime.zero)
          self.player!.play()
           // ithe likh le madam
        }
      })
    }
  }
    //Play Video
    func playVideo(url:URL) {
      player = AVPlayer.init(url: url)
      let playerLayer = AVPlayerLayer(player: player)
//      playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
      playerLayer.frame = viewVideo.bounds
      if self.judgeID == Auth.auth().currentUser?.uid || gameWinnerID.count > 0 {
        viewJudge.layer.addSublayer(playerLayer)
      } else {
        viewVideo.layer.addSublayer(playerLayer)
      }
    //    player?.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
    }
  
   
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "rate" {
            if player!.rate > 0.0 {
                
            }
        }
    }
    
    
  //MARK: ACTIONS
  
    func rewardPlayerAction(_ sender:Int)  {
//    sender.setImage(#imageLiteral(resourceName: "Yello"), for: .normal)
  
    // perform further actions
    let userCommentDic = usersComments[sender] as! [String: String]
    ref.child("rooms").child(self.groupId).child("players").child(userCommentDic["id"]!).child("score").observeSingleEvent(of: .value, with: { (snapshot) in
      if let score = snapshot.value as? Int {
        ref.child("rooms").child(self.groupId).child("players").child(userCommentDic["id"]!).child("score").setValue(score + 1)
      } else {
        ref.child("rooms").child(self.groupId).child("players").child(userCommentDic["id"]!).child("score").setValue(1)
      }
    })
      winnerRef?.setValue(userCommentDic["id"]!)
    
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return usersComments.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let userCommentDic = usersComments[indexPath.row] as! [String: String]
    let captionCell = captionTableView.dequeueReusableCell(withIdentifier: "captionCell", for: indexPath) as! CaptionCell
//         NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: captionCell.player!.currentItem)
//    }
    captionCell.lblCaption.text = userCommentDic["comment"]
    
//    captionCell.btnReward.tag = indexPath.row
//    captionCell.btnReward.addTarget(self, action: #selector(self.rewardPlayerAction(_:)), for: .touchUpInside)
    return captionCell
  }
  
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
    return UITableView.automaticDimension
  }
  
//  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    if self.judgeID == Auth.auth().currentUser?.uid {
//      self.rewardPlayerAction(indexPath.row)
//    }
//  }
  
  
  func observerGameFinish()  {
    
    hasBeenJudgeRef?.observe(.value, with: { (snapshot) in
      if let gameFinished = snapshot.value as? Bool {
        if gameFinished == true {
          self.hasBeenJudgeRef?.removeAllObservers()
          if self.totalUser != self.round {
//          self.performSegue(withIdentifier: "game_Over", sender: self)
            Group.singleton.stopTimer()
            if self.judgeID == Auth.auth().currentUser?.uid {
              var viewControllers = self.navigationController?.viewControllers
              viewControllers?.removeLast(2) // views to pop
              self.navigationController?.setViewControllers(viewControllers!, animated: true)
            } else {
              self.navigationController?.popViewController(animated: true)
            }
          }
        }
      }
    })
    
  }
  
  
  func getUserName(_ ID : String, _ defaultValue : String, _ response :@escaping (_ name : String) ->()) {
    ref.child("Users").child(ID).observeSingleEvent(of: .value, with: { (snapshot) in
      if let userResponse = snapshot.value as? [String: Any] {
        if let name = userResponse["username"] as? String {
          response(name)
        } else {
          response(defaultValue)
        }
      } else {
        response(defaultValue)
      }
    })
  }
  
  func updateNumberOfUsersCommented() {
    let main_string = "\(usersComments.count)/\(Group.singleton.totalUser - 1) captions submitted to the Judge!"
    let string_to_color = "\(usersComments.count)/\(totalUser - 1)"
    
    let range = (main_string as NSString).range(of: string_to_color)
    let attribute = NSMutableAttributedString.init(string: main_string)
    attribute.addAttribute(NSAttributedString.Key.foregroundColor, value: #colorLiteral(red: 0.9630501866, green: 0.443431586, blue: 0.1741285622, alpha: 1) , range: range)
    attribute.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 17), range: range)
    self.textReadyUsers.attributedText = attribute
  }
  
  //MARK :- Judge options
  
  @IBAction func previousImage(_ sender: Any) {
    currentCommentIndex -= 1
    if currentCommentIndex >= 0 && currentCommentIndex < usersComments.count {
      let userCommentDic = usersComments[currentCommentIndex] as! [String: String]
      if gameWinnerID.count > 0 {
        self.updateNameWithComment(userCommentDic["id"]!)
      }
        self.animateTableView(subtype: CATransitionSubtype.fromLeft.rawValue)
      self.textSingleComment.text = userCommentDic["comment"]
      btnNext.isEnabled = true
      btnNext.alpha = 1
      btnWinnerNext.isEnabled = true
      btnWinnerNext.alpha = 1
      if currentCommentIndex <= 0 {
        btnPrevious.isEnabled = false
        btnPrevious.alpha = 0.5
        btnWinnerPrev.isEnabled = false
        btnWinnerPrev.alpha = 0.5
      }
    } else {
      btnPrevious.isEnabled = false
      btnPrevious.alpha = 0.5
      btnWinnerPrev.isEnabled = false
      btnWinnerPrev.alpha = 0.5
      currentCommentIndex = 0
    }
  }
  @IBAction func nextImage(_ sender: Any) {
    currentCommentIndex = currentCommentIndex + 1
    if currentCommentIndex  >= 0 && currentCommentIndex < usersComments.count {
      btnPrevious.isEnabled = true
      btnPrevious.alpha = 1
      btnWinnerPrev.isEnabled = true
      btnWinnerPrev.alpha = 1
      let userCommentDic = usersComments[currentCommentIndex] as! [String: String]
      if gameWinnerID.count > 0 {
        self.updateNameWithComment(userCommentDic["id"]!)
      }
        self.animateTableView(subtype: CATransitionSubtype.fromRight.rawValue)
      self.textSingleComment.text = userCommentDic["comment"]

      if currentCommentIndex >= usersComments.count - 1 {
        btnNext.isEnabled = false
        btnNext.alpha = 0.5
        btnWinnerNext.isEnabled = false
        btnWinnerNext.alpha = 0.5
      }
    } else {
      btnNext.isEnabled = false
      btnNext.alpha = 0.5
      btnWinnerNext.isEnabled = false
      btnWinnerNext.alpha = 0.5
      currentCommentIndex = usersComments.count - 1
    }
  }
  @IBAction func setImage(_ sender: Any) {
    if currentCommentIndex  >= 0 && currentCommentIndex < usersComments.count {
      Group.singleton.sendNotification(Constant.finishedJudging)
    self.rewardPlayerAction(currentCommentIndex)
    }
  }
  
  @IBAction func actionNextRound(_ sender: Any) {
    if totalUser <= round {
//      self.performSegue(withIdentifier: "scoreboard_Segue", sender: self)
      let controller = self.storyboard?.instantiateViewController(withIdentifier: "ResultVC") as! ResultVC
      Group.singleton.stopTimer()
      controller.curPin = self.groupId
      self.navigationController?.pushViewController(controller, animated: true)
    } else {
    readyNextRoundRef?.child(currentUserId!).setValue(true)
    player?.pause()
    self.viewWaiting.isHidden = false
    }
  }
  
  func oberverAllPlayersReady() {
    readyNextRoundRef?.observe(.value, with: { (snapshot) in
      if let readyPlayers = snapshot.value as? [String:Bool] {
        let allKeys = (readyPlayers as NSDictionary).allKeys as! [String]
        print("Current \(self.currentUserId!)")
        print("All Keys Found \(allKeys)")
        self.playersReady = allKeys.count
        if allKeys.count != self.totalUser {
            return
          }
        let id = allKeys[0]
        if id == getUserId() {
          Group.singleton.sendNotification(Constant.nextRound)
        }
        self.readyNextRoundRef?.removeValue()
        self.hasBeenJudgeRef?.setValue(true)
      }
    })
  }
  
  func observerWinnerOfGame() {
    winnerRef?.observe(.value, with: { (snapshot) in
      if let winner =  snapshot.value as? String {
        self.viewSingleImage.isHidden = false
        self.gameWinnerID = winner
        self.player?.pause()
        self.updateMemeMedia()
        self.viewWinnerName.isHidden = false
        self.viewWinnerButtons.isHidden = false
        self.getUserName(winner, "Winner", { (winnerName) in
          self.textJudgeName.text = "\(winnerName) won this round!"
          self.textWinnerName.text = winnerName
          self.viewWinnerName.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
          self.btnPrevious.alpha = 0.5
          self.btnPrevious.isEnabled = false
          self.btnWinnerPrev.alpha = 0.5
          self.btnWinnerPrev.isEnabled = false
          if self.usersComments.count == 1 {
            self.btnNext.alpha = 0.5
            self.btnNext.isEnabled = false
            self.btnWinnerNext.alpha = 0.5
            self.btnWinnerNext.isEnabled = false
          } else {
            self.btnNext.alpha = 1
            self.btnNext.isEnabled = true
            self.btnWinnerNext.alpha = 1
            self.btnWinnerNext.isEnabled = true
          }
        })
        for (index, comment) in self.usersComments.enumerated() {
          let commentDic = comment as! [String: String]
          if commentDic["id"] == winner {
            self.currentCommentIndex = 0
            self.textSingleComment.text = commentDic["comment"]
            self.usersComments.remove(at: index)
            self.usersComments.insert(commentDic, at: 0)
            
          }
        }
      }
    })
  }
  
  func updateNameWithComment(_ id : String) {
    self.textWinnerName.text = ""
    self.getUserName(id, "Default User", { (name) in
      self.textWinnerName.text = name
    })
    if id == self.gameWinnerID {
      self.viewWinnerName.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
    } else {
      self.viewWinnerName.backgroundColor = #colorLiteral(red: 0.8314073351, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
    }
  }
  
    @objc func alertErroOccured(_ notification: NSNotification) {
    
    if let wasJudge = notification.userInfo?["isJudge"] as? Bool {
      // do something with your image
      self.totalUser = Group.singleton.totalUser
      self.round = Group.singleton.round
      if totalUser <= round {
        btnNextRounds.setTitle("Score Board", for: .normal)
      }
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
        
        let controller = UIAlertController(title: "Error: Something went wrong", message: "The judge left the game", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .cancel) { (action) in
          self.navigationController?.popViewController(animated: true)
        }
        controller.addAction(action)
        self.present(controller, animated: true, completion: nil)
        
      } else {
        if self.totalUser - 1 != self.usersComments.count && self.gameWinnerID.count == 0  {
          self.totalUser = Group.singleton.totalUser
          if self.totalUser - 1 == self.usersComments.count {
            Group.singleton.stopTimer()
            Group.singleton.startTime()
            var id = self.getUserID(0)
            if id == self.judgeID {
              id = self.getUserID(1)
            }
            if id == getUserId() {
              Group.singleton.sendNotificationToJudge(self.judgeID, Constant.selectCaption)
            }
            self.textReadyUsers.text = "Wait for \(self.strJudgeName) to pick funniest caption!"
          } else {
            if self.playersReady == self.totalUser {
              self.readyNextRoundRef?.removeValue()
              self.hasBeenJudgeRef?.setValue(true)
            }
          }
        }
      }
      
    }
  }
  
    @IBAction func leave(_ sender: Any){
      let controller = UIAlertController(title: "The game is still in progress!", message: "Are you sure you want to leave? if you leave, your friends will no longer be able to keep on playing", preferredStyle: .alert)
      let leave = UIAlertAction(title: "Leave", style: .default) { (action) in
        Group.singleton.removeErrorObservers()
        let currentUser = Auth.auth().currentUser?.uid
        ref.child("rooms").child(self.groupId).child("players").child(currentUser!).removeValue()
        self.navigationController?.popToRootViewController(animated: true)
      }
      let cancel = UIAlertAction(title: "Stay", style: .cancel, handler: nil)
      controller.addAction(leave)
      controller.addAction(cancel)
      self.present(controller, animated: true, completion: nil)
    }
  
  @IBAction func actionSaveMedia(_ sender: Any){
    if mediaType == 1 {
     let image = UIImage(view: self.saveMediaView)
      UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
      self.showAlert(message: "Your meme has been successfully saved")
    } else {
      saveVideoToPath(self.memeURL, completion: { (success, filePath) in
        UISaveVideoAtPathToSavedPhotosAlbum(filePath, self, nil, nil)
        self.showAlert(message: "Your meme has been successfully saved")
      })
//        if saveClicked == false{
//            if oncePlayed == true{
//                saveClicked = true
//                SVProgressHUD.show()
//                print("video started")
//                glimpse.startRecording(saveMediaView, withCallback: { (url) in
//                    print("video ended")
//                    self.saveClicked = false
//                    SVProgressHUD.dismiss()
//                    self.videoSaved = url?.relativePath
//                    UISaveVideoAtPathToSavedPhotosAlbum( self.videoSaved!, self, nil, nil)
//                    self.showAlert(message: "Your video was successfully saved")
//
//                })
//                let time : Int = Int(CMTimeGetSeconds((self.player?.currentItem?.asset.duration)!))
//
//                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(time), execute: {
//                    self.glimpse.stop()
//                    print("video ends here")
//
//                    // Put your code which should be executed with a delay here
//                })
//            }
//            else{
//                self.showAlert(message: "Video is preparing please wait")
//            }
//        }else{
//            return
//        }
    }
  }
  
  @IBAction func actionShareMedia(_ sender: Any) {
    if mediaType == 1 {
      let image = UIImage(view: self.saveMediaView)
      self.shareImage(image)
    } else {
        
      self.shareVideo(memeURL)
    }
  }
  
  func saveVideoToPath(_ url: String, completion: @escaping (_ result: Bool, _ filePath: String)->()) {
    if videoSaved != nil {
      completion(true, videoSaved!)
      return
    }
    SVProgressHUD.show()
    let videoURL = URL(string:url)
    let urlData = NSData.init(contentsOf: videoURL!)
    DispatchQueue.global(qos: .background).async {
      if ((urlData) != nil){
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDirectory = paths[0]
        let filePath = "\(docDirectory)/tmpVideo.mov"
        urlData?.write(toFile: filePath, atomically: true)
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
          self.videoSaved = filePath
          completion(true, filePath)
        }
      } else {
        DispatchQueue.main.async {
          SVProgressHUD.dismiss()
          self.showAlert(message: "Unable to get video")
          return
        }
      }
    }
    
  }
    
  func shareVideo(_ url : String) {
      // file saved
//    let filePath = saveVideoToPath(url, completion: nil)
    saveVideoToPath(url) { (result, filePath) in
      let videoLink = NSURL(fileURLWithPath: filePath)
      let objectsToShare = [videoLink] as [Any] //comment!, imageData!, myWebsite!]
      let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

      activityVC.setValue("Video", forKey: "subject")
      self.excludeshareExtensions(activityVC)
      self.present(activityVC, animated: true, completion: nil)
    }
    }
    
    
  
  func shareImage(_ image : UIImage) {
    // file saved
    //      let filePath = saveVideoToPath(url)
    if mediaData == nil {
    mediaData = image.jpegData(compressionQuality: 1)
    }
    let objectsToShare = [mediaData!] as [Any] //comment!, imageData!, myWebsite!]
      let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
      excludeshareExtensions(activityVC)
      self.present(activityVC, animated: true, completion: nil)
  }
  
  func excludeshareExtensions(_ activityVC: UIActivityViewController) {
    //New Excluded Activities Code
    if #available(iOS 9.0, *) {
        activityVC.excludedActivityTypes = [ UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.openInIBooks, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print]
    } else {
      // Fallback on earlier versions
        activityVC.excludedActivityTypes = [ UIActivity.ActivityType.addToReadingList, UIActivity.ActivityType.assignToContact, UIActivity.ActivityType.copyToPasteboard, UIActivity.ActivityType.postToTencentWeibo, UIActivity.ActivityType.postToVimeo, UIActivity.ActivityType.postToWeibo, UIActivity.ActivityType.print ]
    }
  }
  
  //kCATransitionFromLeft
  func animateTableView(subtype:String)  {
    let transition = CATransition()
    
    transition.type = CATransitionType.push
    
    transition.subtype = CATransitionSubtype(rawValue: subtype)
    self.textSingleComment.layer.add(transition, forKey: kCATransition)
    CATransaction.commit()
  }
  
}

