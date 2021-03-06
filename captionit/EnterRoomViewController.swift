import UIKit
import FirebaseDatabase
import FirebaseAuth
import SwiftyGif


//  TODO: CHANGE THE TABLE SO IT DISPLAYS THE PLAYERS BASED ON FIREBASE CHANGE MAKE SURE THAT "ISREADY" CHANGES INDIVIDUALLY THEN START GAME GO DIRECTLY TO CAPTIONING AND SHOW IMAGE BASED ON URL.ADD TEXT AND SAVE BOTH SEPARATELY

class EnterRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  var ref:DatabaseReference! = Database.database().reference()
  var curPin: String = "0"
  var playerReady = false
  var users = [Any]()
  var playersReady = 0
  var gameStartRef: DatabaseReference?
  var isFull = false
  var isSecondTime: Bool?
  var removeObserverRef : DatabaseReference?
  
  @IBOutlet weak var labelMemeTimer: UILabel!
  @IBOutlet weak var labelPlayerCount: UILabel!
  @IBOutlet weak var btnStartGame: UIButton!
  @IBOutlet weak var btnAddMeme: UIButton!
  @IBOutlet weak var btnInvite: UIButton!
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    removeObserverRef = ref.child("rooms").child(self.curPin).child("removeUser")
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
    gameStartRef = ref.child("rooms").child(curPin).child("isPlaying")
    gameStartRef?.setValue(false)
    print("hello from enter room controller")
    roomPin.text = "Game Pin: \(curPin)"
    Group.singleton.curPin = curPin
     Group.singleton.isImageUploaded = false
    if Group.singleton.isStrange {
      labelMemeTimer.isHidden = false
    }
    
    // Do any additional setup after loading the view
    //        weak var delegate: UIViewController!
    //PULSATE BUTTONS
    btnAddMeme.pulsate()
    labelPlayerCount.pulsate()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    Group.singleton.delegate = self;
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.userMemeTimerExpired),
      name: NSNotification.Name(rawValue: memeTimerExpired),
      object: nil)
    observeStartGame()
    fetchUsers()
    isSecondTime = nil
    removeUserObserver()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    gameStartRef?.removeAllObservers()
    removeObserverRef?.removeAllObservers()
  }
  
  func userMemeTimerExpired()  {
    let controller = UIAlertController(title: "Error", message: "Time up for meme upload", preferredStyle: .alert)
    let leave = UIAlertAction(title: "Okay", style: .default) { (action) in
      self.navigationController?.popToRootViewController(animated: true)
    }
    controller.addAction(leave)
    self.present(controller, animated: true, completion: nil)
  }
  
  func observeStartGame() {
    gameStartRef?.observe(.value, with: { (snapshot) in
      if let startGame = snapshot.value as? Bool {
        if startGame == true {
          self.gameStartRef?.removeAllObservers()
          Group.singleton.users = self.users
          let controller = self.storyboard?.instantiateViewController(withIdentifier: "CaptioningVC") as! CaptioningVC
          controller.curPin = self.curPin
          self.navigationController?.pushViewController(controller, animated: true)
        }
        else{
            self.btnInvite.pulsate()
            self.labelPlayerCount.pulsate()
        }
      }
    })
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return(users.count)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: "playercell") as! PlayerReadyCell
    cell.imagePlayer.animationManager?.clear()
    if let currentUser = users[indexPath.row] as? [String : Any] {
      let isReady = currentUser["Ready"] as? Bool
         let array = [#imageLiteral(resourceName: "bee-pama"),#imageLiteral(resourceName: "cat-pama"),#imageLiteral(resourceName: "NYE-pama"),#imageLiteral(resourceName: "pirate-pama"),#imageLiteral(resourceName: "snow-pama"),#imageLiteral(resourceName: "st-pats-pama(1)")]
        cell.textName.font = UIFont(name: "SourceCodePro-Bold", size: 16)
        cell.layer.cornerRadius = 3
        cell.layer.masksToBounds = true
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        if isReady == false {
        cell.imagePlayer.image = array[indexPath.row % 6]
        cell.contentView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        //here include arrows for add meme
      }
      else {
        playersReady += 1
        cell.imagePlayer.image = array[indexPath.row % 6] //this is applying for all
        cell.contentView.backgroundColor = #colorLiteral(red: 0.9906545281, green: 0.8612887263, blue: 0.02440710366, alpha: 1)
        if (self.playersReady >= Constant.minUsers && self.playersReady == self.users.count){
                self.labelPlayerCount.text = "PRESS PLAY GAME" //talk to Matt about this change
        }
        if (self.playersReady == 0) {
           self.labelPlayerCount.text = "PRESS ADD MEME"
        }
        self.labelPlayerCount.text =  "\(countPlayersReady())/\(self.users.count) Players Are Ready."
        
      }
      if let ID = currentUser["ID"] as? String {
        self.getUserName(ID, "Undefined User", { (name) in
          cell.textName.text = name
        })
      } else {
        cell.textName.text = currentUser["userName"] as? String
      }
      //cell.textLabel?.text = self.get
    }
    
    return(cell)
    
  }
  
  func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return UIView()
  }
  @IBOutlet weak var roomPin: UILabel!
  
  func fetchUsers() {
    ref.child("rooms").child(curPin).child("players").observe(.value, with: { (snapshot) in
      if let result = snapshot.children.allObjects as? [DataSnapshot] {
        self.users.removeAll()
        for (index, child) in result.enumerated() {
          var value = child.value as! [String : Any]
          value["userName"] = "Undefined User"
          let id = value["ID"] as? String
          if id == getUserId() {
            Group.singleton.userIndex = index
          }
          self.users.append(value)
          //
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: {
          if self.countPlayersReady() == self.users.count && self.users.count > 2 {
            self.btnStartGame.isEnabled = true
            self.btnStartGame.alpha = 1
          } else {
            self.btnStartGame.isEnabled = false
            self.btnStartGame.alpha = 0.5
          }
          if Group.singleton.isStrange && Group.singleton.updatedUsers != self.users.count {
            if self.users.count <= Constant.minUsers {
              if self.isFull {
                self.ref.child("rooms").child(self.curPin).child("isReopen").setValue(true)
              }
              if Group.singleton.timerStarted > 0 {
                self.ref.child("rooms").child(self.curPin).child("isFull").setValue(false)
                Group.singleton.isInactive = false
                Group.singleton.startStrangeTimer()
              } else {
                self.ref.child("rooms").child(self.curPin).child("isFull").setValue(false)
                Group.singleton.isInactive = false
                Group.singleton.startStrangeTimer()
              }
            }
            
          }
          Group.singleton.updatedUsers = self.users.count
          self.tableView.reloadData()
        })
      }
    })
  }
  func countPlayersReady() -> Int { //works maybe put this in functionss and extensions
    var count = 0
    for user in users {
      if let currentUser = user as? [String : Any] {
        let isReady = currentUser["Ready"] as? Bool
        if isReady == true {
          count += 1
        }
      }
      print("\(count) Active Users")
    }
    
    return count
  }
  
  
  
  func displayErrorMsg() {
    let alert = UIAlertController(title: "Can't start game, yet", message: "You need at least 3 players with a meme each to play", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alert, animated: true)
    
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
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  @IBAction func addMeme() {
    let controller = self.storyboard?.instantiateViewController(withIdentifier: "RoomViewController") as! RoomViewController
    controller.curPin = curPin
    self.navigationController?.pushViewController(controller, animated: true)
    
  }
  
  @IBAction func startGame() { //works now
    if (self.countPlayersReady() == users.count && self.countPlayersReady() >= 2){
      gameStartRef?.removeAllObservers()
      Group.singleton.users = users
      gameStartRef?.setValue(true)
      Group.singleton.sendNotification(Constant.startGame)
      Group.singleton.users = self.users
      let controller = self.storyboard?.instantiateViewController(withIdentifier: "CaptioningVC") as! CaptioningVC
      controller.curPin = curPin
      self.navigationController?.pushViewController(controller, animated: true)
    }
    else{
      displayErrorMsg()
    }
  }
  
  @IBAction func InviteFriends() {
    let controller = self.storyboard?.instantiateViewController(withIdentifier: "FBInviteViewController") as! FBInviteViewController
    controller.groupId = curPin
    self.navigationController?.pushViewController(controller, animated: true)
  }
  
  @IBAction func actionBack() {
    let currentUser = Auth.auth().currentUser?.uid
    ref.child("rooms").child(self.curPin).child("players").child(currentUser!).removeValue { (error, reff) in
      Group.singleton.deleteCurrentUserMedia()
      if self.users.count == 0  {
        self.ref.child("rooms").child(self.curPin).removeValue()
      } else if self.users.count == 1 {
        let user = self.users[0] as! [String: Any]
        if (user["ID"] as! String) == getUserId() {
          self.ref.child("rooms").child(self.curPin).removeValue()
        }
      }
      self.navigationController?.popViewController(animated: true)
    }
  }
}

extension EnterRoomViewController : GroupDelegate {
  func memeTimerChanged(_ time: Int) {
    let strTime = Group.singleton.timeFormatted(time)
    if !Group.singleton.isInactive {
     labelMemeTimer.text = "Waiting \n\(strTime)"
    } else {
      self.ref.child("rooms").child(self.curPin).child("isFull").setValue(true)
      isFull = true
     labelMemeTimer.text = "Be Ready in \n\(strTime)"
    }
    if Group.singleton.isInactive == true && time > 2 * 60 {
      Group.singleton.memePickerTimerExpired()
      switchRemoveUserValue()
    }
    if Group.singleton.updatedUsers >= Constant.minUsers && time >= 3 * 60 && Group.singleton.isInactive == false {
      Group.singleton.isInactive = true
      Group.singleton.timerStarted = 0
      Group.singleton.memePickerTimerExpired()
      Group.singleton.groupStartMemePickTimer()
      return
    }
    
  }
  
  func removeUserObserver() {
    removeObserverRef?.observe(.value, with: { (snapshot) in
      guard let _ =  self.isSecondTime else {self.isSecondTime = true; return}
      if let value = snapshot.value as? Bool {
        if Group.singleton.isImageUploaded == false {
          self.removeUser()
        }
      }
    })
  }
  
  func switchRemoveUserValue() {
    removeObserverRef?.observe(.value, with: { (snapshot) in
      if let value = snapshot.value as? Bool {
        self.ref.child("rooms").child(self.curPin).child("removeUser").setValue(!value)
      } else {
        self.ref.child("rooms").child(self.curPin).child("removeUser").setValue(true)
      }
    })
  }
  
  func removeUser() {
    let currentUser = Auth.auth().currentUser?.uid
    ref.child("rooms").child(self.curPin).child("players").child(currentUser!).removeValue { (error, reff) in
      Group.singleton.deleteCurrentUserMedia()
      if self.users.count == 0  {
        self.ref.child("rooms").child(self.curPin).removeValue()
      } else if self.users.count == 1 {
        let user = self.users[0] as! [String: Any]
        if (user["ID"] as! String) == getUserId() {
          self.ref.child("rooms").child(self.curPin).removeValue()
        }
      }
      self.navigationController?.popViewController(animated: true)
    }
  }
}
