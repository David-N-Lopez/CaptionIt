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
        fetchUsers()
      observeStartGame()
      
        
        // Do any additional setup after loading the view
        //        weak var delegate: UIViewController!
    }
    
  override func viewWillDisappear(_ animated: Bool) {
    gameStartRef?.removeAllObservers()
  }
  
  func observeStartGame() {
    gameStartRef?.observe(.value, with: { (snapshot) in
      if let startGame = snapshot.value as? Bool {
        if startGame == true {
          self.performSegue(withIdentifier: "gameIsOn!", sender: Any?.self)
        }
      }
    })
  }
  
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(users.count)
    }
  
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "playercell")
        let notReadyImage : UIImage = UIImage(named: "notready.png")!
        if let currentUser = users[indexPath.row] as? [String : Any] {
            let isReady = currentUser["Ready"] as? Bool
            if isReady == false {
                cell.imageView?.image = notReadyImage
            }
            else{
                cell.imageView?.image = #imageLiteral(resourceName: "pama") //this is applying for all
            }
            if let ID = currentUser["ID"] as? String {
                self.getUserName(ID, "Default User", { (name) in
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
                  let orderID = child.key
                    var value = child.value as! [String : Any]
                    value["userName"] = orderID
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
//                ref.child("rooms").child(curPin).child("players").observeSingleEvent(of: .value, with: { snapshot in
//                    // I got the expected number of items
//                    let enumerator = snapshot.children
//                    while let rest = enumerator.nextObject() as? DataSnapshot {
//                        let curRoom = rest.childSnapshot(forPath: "Ready").value as! Bool
//                        if curRoom == true {
//                            count+=1
//        
//                        }
//                    }
//                })
        return count
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
        performSegue(withIdentifier: "addmeme", sender: self)
    }
    
     @IBAction func startGame() { //works now
        if  self.countPlayersReady() == users.count{
          gameStartRef?.setValue(true)
           self.performSegue(withIdentifier: "gameIsOn!", sender: Any?.self)
        }
        //        if playersReady>2 {
        //        performSegue(withIdentifier: "gameIsOn!", sender: Any?)
        //        }
    }
    @IBAction func unwindSegueToRoomVC(_ sender:UIStoryboardSegue) { }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addmeme" {
            let controller = segue.destination as! RoomViewController
            controller.curPin = curPin
        }
        if segue.identifier == "gameIsOn!" {
            let controller = segue.destination as! CaptioningVC
            controller.curPin = curPin
            
            
        }
    
}
}
