import UIKit
import FirebaseDatabase
import FirebaseAuth
//  TODO: CHANGE THE TABLE SO IT DISPLAYS THE PLAYERS BASED ON FIREBASE CHANGE MAKE SURE THAT "ISREADY" CHANGES INDIVIDUALLY THEN START GAME GO DIRECTLY TO CAPTIONING AND SHOW IMAGE BASED ON URL.ADD TEXT AND SAVE BOTH SEPARATELY

class EnterRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  var ref:DatabaseReference! = Database.database().reference()
  var curPin: String = "0"
  var playerReady = false
  var users = [Any]()
  var playersReady = 0
  var gameStartRef: DatabaseReference?
  
  @IBOutlet weak var tableView: UITableView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    gameStartRef = ref.child("rooms").child(curPin).child("isPlaying")
    gameStartRef?.setValue(false)
    print("hellow from enter room controller")
    roomPin.text = "Room Pin Number: \(curPin)"
    // Do any additional setup after loading the view
    //        weak var delegate: UIViewController!
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
      }
    })
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return(users.count)
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "playercell")
    if let currentUser = users[indexPath.row] as? [String : Any] {
      let isReady = currentUser["Ready"] as? Bool
      if isReady == false {
        cell.imageView?.image = UIImage.gifImageWithName(name: "pama-loading-screen")
      }
      else{
        let array = [#imageLiteral(resourceName: "bee-pama"),#imageLiteral(resourceName: "cat-pama"),#imageLiteral(resourceName: "NYE-pama"),#imageLiteral(resourceName: "pirate-pama"),#imageLiteral(resourceName: "snow-pama"),#imageLiteral(resourceName: "st-pats-pama(1)")]
        let num = UInt32(array.count)
        let random = Int(arc4random_uniform(num))
        cell.imageView?.image = array[random] //this is applying for all
      }
      if let ID = currentUser["ID"] as? String {
        self.getUserName(ID, "Undefined User", { (name) in
          cell.textLabel?.text = name
        })
      } else {
        cell.textLabel?.text = currentUser["userName"] as? String
      }
      
      //            cell.textLabel?.text = self.get
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
        for child in result {
          var value = child.value as! [String : Any]
          value["userName"] = "Undefined User"
          self.users.append(value)
          //
        }
        
        DispatchQueue.main.async {
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
      Group.singleton.sendNotification("Game Started")
      Group.singleton.users = self.users
      let controller = self.storyboard?.instantiateViewController(withIdentifier: "CaptioningVC") as! CaptioningVC
      controller.curPin = curPin
      self.navigationController?.pushViewController(controller, animated: true)
    }
    else{
      displayErrorMsg()
    }
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
