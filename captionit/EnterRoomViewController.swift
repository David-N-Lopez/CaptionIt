//
//  EnterRoomViewController.swift
//  CaptionIt
//
//  Created by liuting chen on 12/3/17.
//  Copyright © 2017 Tower Org. All rights reserved.
//

import UIKit

class EnterRoomViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var curPins: String = "0"
    weak var delegate: UIViewController!
    var usersNames: [String] = []
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return(usersNames.count)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "playercell")
        let notReadyImage : UIImage = UIImage(named: "notready.png")!
        // let size = CGSize(width: 30, height: 30)
        // let newNotReadyImage = notReadyImage.resizeImageWith(newSize: size)
        cell.imageView?.image = notReadyImage
        cell.textLabel?.text = usersNames[indexPath.row]

        return(cell)
    }


    @IBOutlet weak var roomPin: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hellow from enter room controller")

        roomPin.text = "Room Pin Number: \(curPins)"
        

        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addMeme() {
        performSegue(withIdentifier: "addmeme", sender: self)
    }
    
    @IBAction func startGame() {
    }
    @IBAction func unwindSegueToRoomVC(_ sender:UIStoryboardSegue) { }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
