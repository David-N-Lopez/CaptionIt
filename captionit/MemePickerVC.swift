//
//  RoomViewController.swift
//  CaptionIt
//
//  Created by liuting chen on 12/1/17.
//  Copyright © 2017 Tower Org. All rights reserved.
//

import UIKit
import AVKit
import FirebaseStorage
import FirebaseDatabase

class RoomViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var ref:DatabaseReference! = Database.database().reference()
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myTextView: UILabel!
    
    var curPin:String?
    var previewImage: UIImage?
    var previewVideo: URL?
  
    
    @IBOutlet weak var pickMeme: UIButton!

    @IBAction func submit(_ sender: UIButton) {
        print("start")
        if (myImageView.image != nil){
            let currentPlayer = getCurrentPlayer()
            let image = myImageView.image
            let data : Data = UIImageJPEGRepresentation(image!, 0.4)!
            print(data)
        let storageR = Storage.storage()
        let storageRef = storageR.reference()
            print("before")
            let uploadTask = storageRef.child(curPin!).child((currentPlayer?.username)!).putData(data, metadata: nil) { metadata, error in
                    if error != nil {
                        print("error")
                    } else {
                        //try to make it private
                        let outputURL = (metadata?.downloadURL()?.absoluteString)!
                        self.ref.child("rooms").child(self.curPin!).child("players").child(currentPlayer!.username).updateChildValues(["meme Photo": outputURL, "Ready": true])
                        self.performSegue(withIdentifier: "PlayerHasImageSegue", sender: Any?.self)
                        
                    }
                    
                }}
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        let picker = UIImagePickerController()
        picker.delegate = self // delegate added
        myImageView.image = previewImage
        myTextView.text = "This is a meme. \nNow let's make this absurdly large to fit roughly three wait no let's make it five lines worth of text to really test the limits of this label box. So yeah."
        myTextView.backgroundColor = UIColor.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectPhotoButtonTapped(_ sender: UIButton) {

        let alert = UIAlertController(title: "Where do you want to get your meme from?", message: "You can take footage rn or grab some from your cameraroll, you decide.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "CameraRoll", style: .default, handler: { action in
            self.selectPicture()
        }))
        alert.addAction(UIAlertAction(title: "Make Your Meme", style: .default, handler: { action in
            self.performSegue(withIdentifier: "SwiftyCam", sender: Any?)
        }))

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)

        
    }
    /********************Compresses the Video Maybe include this in the upload section ***********************/
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = "mov" //changing AVFileType.mov to a string
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    func selectPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true)
       
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var newImage: UIImage
        
        if let possibleImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            newImage = possibleImage
        } else {
            return
        }
        
        // do something interesting here!
        pickMeme.setTitle("Change Meme?", for:.normal)
        myImageView.image = newImage
        dismiss(animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SwiftyCam" {
            let controller = segue.destination as! camController
            controller.curPin = curPin
        }
        if segue.identifier == "PlayerHasImageSegue"{
            let controller = segue.destination as! EnterRoomViewController
            controller.playerReady = true
            controller.curPin = self.curPin!
            controller.playersReady += 1
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
