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
import SVProgressHUD
import SwiftyGif

class RoomViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var ref:DatabaseReference! = Database.database().reference()
    
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myTextView: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var carouselView: UIView!
    var curPin:String?
    var previewImage: UIImage?
    var previewVideo: URL?
    var mediaType  = 1
    var player : AVPlayer?
    var pickerGallery = true
  let gifManager = SwiftyGifManager(memoryLimit:10)
    
    //Carousel Variables
    var contentInstance = carouselMemes.fetchInterests()
    let cellScaling: CGFloat = 0.6
    
    @IBOutlet weak var pickMeme: UIButton!

    @IBAction func submit(_ sender: UIButton) {
        print("start")
      self.showProgressHUD()
     if (myImageView.image != nil || previewVideo != nil) { // still need to check that the user is uploading something
        
            let currentPlayer = getCurrentPlayer()
            let image = myImageView.image
            var data =  NSData()
          if mediaType == 1 {
            data = UIImageJPEGRepresentation(image!, 0.4)! as NSData
          } else {
            do {
              data = try NSData.init(contentsOf: previewVideo!)
            } catch(let error) {
              print(error)
            }
          }
        let storageR = Storage.storage()
        let storageRef = storageR.reference()
            print("before")
          
          var playerName = (currentPlayer?.username)!
          if mediaType == 2 {
           playerName = "\(playerName).mov"
          }
          let uploadTask = storageRef.child(curPin!).child(playerName).putData(data as Data, metadata: nil) { metadata, error in
            self.player?.pause()
            SVProgressHUD.dismiss()
                    if error != nil {
                        print("error")
                    } else {
                        //try to make it private
                        let outputURL = (metadata?.downloadURL()?.absoluteString)!
                     Group.singleton.url = outputURL
                      self.ref.child("rooms").child(self.curPin!).child("players").child(getUserId()!).updateChildValues(["memeURL": outputURL, "Ready": true, "mediaType": self.mediaType])
                      if self.pickerGallery {
                        self.navigationController?.popViewController(animated: true)
                      } else {
                        var viewControllers = self.navigationController?.viewControllers
                        viewControllers?.removeLast(4) // views to pop
                        self.navigationController?.setViewControllers(viewControllers!, animated: true)
                      }
                      
                    }
                    
                }}
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        let picker = UIImagePickerController()
        picker.delegate = self // delegate added
        pickMeme.pulsate()
        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScaling)
        let cellHeight = floor(screenSize.height * cellScaling)
        
        let insetX = (view.bounds.width - cellWidth) / 2.0
        let insetY = (view.bounds.height - cellHeight) / 2.0
        
        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView?.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
    }
  
  override func viewDidAppear(_ animated: Bool) {
    if mediaType == 1 {
      if previewImage == nil {
//        //check this out
//        //NICOOOO
//        let gif = UIImage(gifName: "pizza-pama (1)")
//        myImageView.setGifImage(gif, manager: gifManager, loopCount: -1)
        previewView.isHidden = true
        carouselView.isHidden = false
      } else {
        imageUploaded()
      }
    } else {
      //Show Video
      uploadButton.isEnabled = true
      uploadButton.alpha = 1
      playVideo(from: previewVideo!)
    }
    myTextView.text = "Pick an image below, or make your own with your camera roll or taking a picture!"
  }
    func imageUploaded(){
        previewView.isHidden = false
        carouselView.isHidden = true
        uploadButton.isEnabled = true
        uploadButton.alpha = 1
        myImageView.image = previewImage
    }
  
  private func playVideo(from url:URL) {

    player = AVPlayer(url: url)
    
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = self.myImageView.frame
    self.view.layer.addSublayer(playerLayer)
    player?.play()
    NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
  }
  
  @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
    if self.player != nil {
      self.player!.seek(to: kCMTimeZero)
      self.player!.play()
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
  }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectPhotoButtonTapped(_ sender: UIButton) {
          let controller = self.storyboard?.instantiateViewController(withIdentifier: "camController") as! camController
          controller.curPin = self.curPin
          self.navigationController?.pushViewController(controller, animated: true)
    }
    @IBAction func selectCameraRoll(_ sender: UIButton) {
               self.selectPicture()
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
        myImageView.clear()
        // do something interesting here!
        pickMeme.setTitle("Change Meme?", for:.normal)
        myImageView.image = newImage
      previewImage = newImage
        dismiss(animated: true)
    }

  
@IBAction func actionBack(_ sender: UIButton) {
  self.navigationController?.popViewController(animated: true)
  
  }
}
