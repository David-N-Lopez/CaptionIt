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
  
  @IBOutlet weak var btnStartGame: UIButton!
  @IBOutlet weak var btnAddMeme: UIButton!
  @IBOutlet weak var btnInvite: UIButton!
  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
    gameStartRef = ref.child("rooms").child(curPin).child("isPlaying")
    gameStartRef?.setValue(false)
    print("hellow from enter room controller")
    roomPin.text = "ROOM: \(curPin)"
    Group.singleton.curPin = curPin
    // Do any additional setup after loading the view
    //        weak var delegate: UIViewController!
    //PULSATE BUTTONS
    btnAddMeme.pulsate()

  }
  
  override func viewWillAppear(_ animated: Bool) {
    observeStartGame()
    fetchUsers()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    gameStartRef?.removeAllObservers()
  }
  
  func observeStartGame() {
    gameStartRef?.observe(.value, with: { (snapshot) in
      if let startGame = snapshot.value as? Bool {
        if startGame == true {
          //          self.performSegue(withIdentifier: "gameIsOn!", sender: Any?.self)
          self.gameStartRef?.removeAllObservers()
          Group.singleton.users = self.users
          let controller = self.storyboard?.instantiateViewController(withIdentifier: "CaptioningVC") as! CaptioningVC
          controller.curPin = self.curPin
          self.navigationController?.pushViewController(controller, animated: true)
        }
        else{
            self.btnInvite.pulsate()
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
       
        cell.imagePlayer.image = array[indexPath.row % 6] //this is applying for all
        cell.contentView.backgroundColor = #colorLiteral(red: 0.9906545281, green: 0.8612887263, blue: 0.02440710366, alpha: 1)
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
        DispatchQueue.main.async {
          if self.countPlayersReady() == self.users.count && self.users.count > 1 {
            self.btnStartGame.isEnabled = true
            self.btnStartGame.alpha = 1
          } else {
            self.btnStartGame.isEnabled = false
            self.btnStartGame.alpha = 0.5
          }
          self.tableView.reloadData()
        }
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
  func displayErrorMsg(){
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
