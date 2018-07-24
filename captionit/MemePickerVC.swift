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
    @IBOutlet weak var labelMemeTimer: UILabel!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var carouselView: UIView!
    @IBOutlet weak var carouselButtonView: UIView!
    @IBOutlet weak var previewButtonView: UIView!
    @IBOutlet weak var changeMemeButton: UIView!
  @IBOutlet weak var btnBack: UIButton!
  
    var curPin:String?
    var previewImage: UIImage?
    var previewVideo: URL?
    var mediaType  = 1
    var player : AVPlayer?
    var pickerGallery = true
    let gifManager = SwiftyGifManager(memoryLimit:10)
    
    //Carousel Variables
    var contentInstance = [carouselMemes]()
    let cellScaling: CGFloat = 0.6
    
    @IBOutlet weak var pickMeme: UIButton!

  override func viewWillAppear(_ animated: Bool) {
    Group.singleton.delegate = self
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(self.userMemeTimerExpired),
      name: NSNotification.Name(rawValue: timerExpired),
      object: nil)
    carouselMemes.fetchInterests { (arrMeme) in
      self.contentInstance = arrMeme
      self.collectionView.reloadData()
    }
    
  }

  override func viewDidDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
  }
  
    @IBAction func submit(_ sender: UIButton) {
        print("start")
      
      self.showProgressHUD()
     if (myImageView.image != nil || previewVideo != nil) { // still need to check that the user is uploading something
        Group.singleton.memePickerTimerExpired()
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
        showMemeCarousel()
    }
  
  override func viewDidAppear(_ animated: Bool) {
    if mediaType == 1 {
      if previewImage == nil { //showing carousel view
        btnBack.isHidden = false
        print("no image")
        showMemeCarousel()
        myTextView.text = "Pick one of our suggested images, or make your own MEME!"
        uploadButton.isEnabled = false
        uploadButton.alpha = 0.5
        
      } else { //showing selected image view
        print("image")
        imageUploaded()
        myTextView.text = "Upload your selected meme or change it!"

      }
    } else {
      //Show Video view
      btnBack.isHidden = true
        print("video")
      myTextView.text = "Upload your selected meme or change it!"
      Group.singleton.memePickerTimerExpired()
      carouselView.isHidden = true
      carouselButtonView.isHidden = true
      uploadButton.isEnabled = true
      uploadButton.alpha = 1
      playVideo(from: previewVideo!)
        
    }
  }
    func imageUploaded(){
        previewView.isHidden = false
        carouselView.isHidden = true
        uploadButton.isEnabled = true
        previewButtonView.isHidden = false
        carouselButtonView.isHidden = true
        uploadButton.alpha = 1
        myImageView.image = previewImage
    }
    func showMemeCarousel(){
        previewView.isHidden = true
        carouselView.isHidden = false
        previewButtonView.isHidden = true
        carouselButtonView.isHidden = false
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
    @IBAction func changeMeme(){
        uploadButton.isEnabled = false
        uploadButton.alpha = 0.5
        showMemeCarousel()
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
      Group.singleton.memePickerTimerExpired()
        myImageView.image = newImage
      previewImage = newImage
        dismiss(animated: true)
    }
  
@IBAction func actionBack(_ sender: UIButton) {
  self.navigationController?.popViewController(animated: true)
  
  }
  
  func userMemeTimerExpired()  {
    let controller = UIAlertController(title: "Error", message: "Time up for meme upload", preferredStyle: .alert)
    let leave = UIAlertAction(title: "Okay", style: .default) { (action) in
      self.navigationController?.popToRootViewController(animated: true)
    }
    controller.addAction(leave)
    self.present(controller, animated: true, completion: nil)
  }
}

extension RoomViewController : GroupDelegate {
  func memeTimerChanged(_ time: Int) {
    labelMemeTimer.text = Group.singleton.timeFormatted(time)
  }
}
