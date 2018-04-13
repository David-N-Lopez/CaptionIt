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

class JudgementVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
  @IBOutlet weak var btnNext: UIButton!
  @IBOutlet weak var btnPrevious: UIButton!
  @IBOutlet weak var viewSingleImage: UIView!
  @IBOutlet weak var imageCaption: UIImageView!
  @IBOutlet weak var viewVideo: UIView!
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
  var round = 0
  var totalUser = 0
  var currentCommentIndex = 0
  var gameWinnerID = ""
  let currentUserId = Auth.auth().currentUser?.uid

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
    getUserName(judgeID, "Default user") { (name) in
      self.strJudgeName = name
      if Auth.auth().currentUser?.uid == self.judgeID {
        self.textRound.text = "ROOM #\(self.groupId)"
        self.textJudgeName.text = "The Crazy Developers"
      } else {
        self.textJudgeName.text = "\(name) is the judge!"
      }
    }
    hasBeenJudgeRef = ref.child("rooms").child(groupId).child("players").child(judgeName).child("hasBeenJudge")
    winnerRef = ref.child("rooms").child(groupId).child("comments").child(judgeName).child("winner")
    getAllComments()
    updateMemeMedia()
    observerGameFinish()
    observerWinnerOfGame()
    updateNumberOfUsersCommented()
    self.textRound.text = "Round \(round)"
    captionTableView.dataSource = self
    captionTableView.delegate = self
    captionTableView.estimatedRowHeight = 300
    captionTableView.tableFooterView = UIView()
    if self.judgeID == Auth.auth().currentUser?.uid {
      viewSingleImage.isHidden = false
    }
    if totalUser == round {
      btnNextRounds.setTitle("Score Board", for: .normal)
    }

    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    player?.pause()
    NotificationCenter.default.removeObserver(self)
    hasBeenJudgeRef?.removeAllObservers()
    winnerRef?.removeAllObservers()
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
        if self.currentCommentIndex == 0 && Auth.auth().currentUser?.uid == self.judgeID {
          let comment = self.usersComments[0] as! [String : Any]
          self.textSingleComment.text = comment["comment"] as? String
        }
        if self.totalUser - 1 == self.usersComments.count {
          self.textReadyUsers.text = "Wait for \(self.strJudgeName) to pick funniest meme!"
        } else {
          self.updateNumberOfUsersCommented()
        }
        self.captionTableView.reloadData()
      }
      
    })
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
        player!.seek(to: kCMTimeZero)
        player?.play()
      }
      NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object:player!.currentItem , queue:nil , using: { (_ notification: Notification) in
        if self.player != nil {
          self.player!.seek(to: kCMTimeZero)
          self.player!.play()
        }
      })
    }
  }
    //Play Video
    func playVideo(url:URL) {
      player = AVPlayer.init(url: url)
      let playerLayer = AVPlayerLayer(player: player)
      playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
      playerLayer.frame = viewVideo.bounds
      if self.judgeID == Auth.auth().currentUser?.uid || gameWinnerID.count > 0 {
        viewJudge.layer.addSublayer(playerLayer)
      } else {
        viewVideo.layer.addSublayer(playerLayer)
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
    
    return UITableViewAutomaticDimension
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
          if self.totalUser == self.round {
            self.performSegue(withIdentifier: "scoreboard_Segue", sender: self)
           
          } else {
          self.performSegue(withIdentifier: "game_Over", sender: self)
          }
        }
      }
    })
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    if segue.identifier == "game_Over" {
      if let destinationVC = segue.destination as? CaptioningVC {
        destinationVC.curPin = self.groupId
      }
    } else if segue.identifier == "scoreboard_Segue" {
      if let destinationVC = segue.destination as? ResultVC {
        destinationVC.curPin = self.groupId
      }
    }
    
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
    let main_string = "\(usersComments.count)/\(totalUser - 1) memes are ready to go!"
    let string_to_color = "\(usersComments.count)/\(totalUser - 1)"
    
    let range = (main_string as NSString).range(of: string_to_color)
    let attribute = NSMutableAttributedString.init(string: main_string)
    attribute.addAttribute(NSForegroundColorAttributeName, value: #colorLiteral(red: 0.9630501866, green: 0.443431586, blue: 0.1741285622, alpha: 1) , range: range)
    attribute.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 17), range: range)
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
      textSingleComment.text = userCommentDic["comment"]
      btnNext.isEnabled = true
      if currentCommentIndex <= 0 {
        btnPrevious.isEnabled = false
      }
    } else {
        currentCommentIndex = 0
    }
  }
  @IBAction func nextImage(_ sender: Any) {
    currentCommentIndex += 1
    if currentCommentIndex  >= 0 && currentCommentIndex < usersComments.count {
      btnPrevious.isEnabled = true
      let userCommentDic = usersComments[currentCommentIndex] as! [String: String]
      if gameWinnerID.count > 0 {
        self.updateNameWithComment(userCommentDic["id"]!)
      }
      textSingleComment.text = userCommentDic["comment"]
      if currentCommentIndex >= userCommentDic.count {
        btnNext.isEnabled = false
      }
    } else {
      currentCommentIndex = usersComments.count - 1
    }
  }
  @IBAction func setImage(_ sender: Any) {
    if currentCommentIndex  >= 0 && currentCommentIndex < usersComments.count {
    self.rewardPlayerAction(currentCommentIndex)
    }
  }
  
  @IBAction func actionNextRound(_ sender: Any) {
    self.hasBeenJudgeRef?.setValue(true)
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
          self.textJudgeName.text = "\(winnerName) is the winner"
          self.textWinnerName.text = winnerName
          self.viewWinnerName.backgroundColor = #colorLiteral(red: 0.2458627252, green: 1, blue: 0.003417990503, alpha: 1)
        })
        for (index, comment) in self.usersComments.enumerated() {
          let commentDic = comment as! [String: String]
          if commentDic["id"] == self.currentUserId {
            self.currentCommentIndex = index
            self.textSingleComment.text = commentDic["comment"]
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
      self.viewWinnerName.backgroundColor = #colorLiteral(red: 0.2458627252, green: 1, blue: 0.003417990503, alpha: 1)
    } else {
      self.viewWinnerName.backgroundColor = #colorLiteral(red: 0.9785731435, green: 0.07145081846, blue: 0.007269420236, alpha: 1)
    }
  }
}

