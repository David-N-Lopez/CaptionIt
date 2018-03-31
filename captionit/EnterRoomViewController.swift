//
//  EnterRoomViewController.swift
//  CaptionIt
//
//  Created by liuting chen on 12/3/17.
//  Copyright © 2017 Tower Org. All rights reserved.
//

import UIKit
import FirebaseDatabase
//  TODO: CHANGE THE TABLE SO IT DISPLAYS THE PLAYERS BASED ON FIREBASE CHANGE MAKE SURE THAT "ISREADY" CHANGES INDIVIDUALLY THEN START GAME GO DIRECTLY TO CAPTIONING AND SHOW IMAGE BASED ON URL.ADD TEXT AND SAVE BOTH SEPARATELY 

class EnterRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var ref:DatabaseReference! = Database.database().reference()
    var curPin: String = "0"
    var playerReady = false
    var usersNames: [String] = []
    var playersReady = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hellow from enter room controller")
        roomPin.text = "Room Pin Number: \(curPin)"
           fetchUsers()
        // Do any additional setup after loading the view
        //        weak var delegate: UIViewController!
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        return(usersNames.count)
      
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "playercell")
        let notReadyImage : UIImage = UIImage(named: "notready.png")!
        if playerReady == false {
        cell.imageView?.image = notReadyImage
        }
        else{
            cell.imageView?.image = #imageLiteral(resourceName: "pama") //this is applying for all
        }
        cell.textLabel?.text = usersNames[indexPath.row]
        return(cell)
      
    }
    @IBOutlet weak var roomPin: UILabel!
    func fetchUsers(){
       ref.child("rooms").child(curPin).child("players").observe(.value, with: { (snapshot) in
                if let result = snapshot.children.allObjects as? [DataSnapshot] {
                    for child in result {
                        var orderID = child.key as! String
                        self.usersNames.append(orderID)
                        //
                    }
                }
            })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    func countPlayersReady()->Int{ //works maybe put this in functionss and extensions
        var count = 0
        ref.child("rooms").child(curPin).child("players").observeSingleEvent(of: .value, with: { snapshot in
            // I got the expected number of items
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? DataSnapshot {
                let curRoom = rest.childSnapshot(forPath: "Ready").value as! Bool
                if curRoom == true {
                    count+=1
                    
                }
            }
        })
        return count
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addMeme() {
        performSegue(withIdentifier: "addmeme", sender: self)
    }
    
    @IBAction func startGame() {
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
    }
    
    
 
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
