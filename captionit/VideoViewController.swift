/*Copyright (c) 2016, Andrew Walz.
 
 Redistribution and use in source and binary forms, with or without modification,are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
 BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

import UIKit
import AVFoundation
import AVKit
import FirebaseStorage
import FirebaseDatabase

class VideoViewController: UIViewController {
  
    var ref:DatabaseReference! = Database.database().reference()
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    var videoURL: URL?
    let currentPlayer = getCurrentPlayer()?.username
    let compressedURL = NSURL.fileURL(withPath: "Video.mp4")
    var player: AVPlayer?
    var playerController : AVPlayerViewController?
    var curPin:String?
    
//    init(videoURL: URL, pin: String?) {
//        self.videoURL = videoURL
//        super.init(nibName: nil, bundle: nil)
//        curPin = pin
//
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
  
    /********************Sets buttons and everything that appears after filming***********************/
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray
        playerController = AVPlayerViewController()
        player = AVPlayer(url: videoURL!)
        guard player != nil && playerController != nil else {
            return
        }
      playerController!.player = player!
        playerController!.showsPlaybackControls = false
      
        self.addChildViewController(playerController!)
        self.view.addSubview(playerController!.view)
        playerController!.view.frame = view.frame
      
        
        let cancelButton = UIButton(frame: CGRect(x: 20.0, y: 20.0, width: 30.0, height: 30.0))
        cancelButton.setImage(#imageLiteral(resourceName: "close-button"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        let useIcon = UIButton(frame: CGRect(x: view.frame.size.width - 90, y: view.frame.size.height - 90 , width: 80.0, height: 80.0))
        useIcon.setImage(#imageLiteral(resourceName: "contrast-arrow-black"), for: UIControlState())
        useIcon.addTarget(self, action: #selector(useVideo), for: .touchUpInside)
        view.addSubview(useIcon)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      player = AVPlayer(url: videoURL!)
      playerController!.player = player!
//      playerController?.videoGravity = AVLayerVideoGravityResizeAspectFill
        player?.play()
      NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
    }
  
  override func viewDidDisappear(_ animated: Bool) {
    player?.pause()
  }
  
    /********************Dismisses the view***********************/
    func cancel() {
      self.navigationController?.popViewController(animated: true)
    }

    /********************Use video will store the url under your name
                            Later to be saved in the storage when you choose to upload
     There is a potential bug here: the pinNumber variable is saved when a player joins the game there is nothing that changes it in the case that the player leaves the game***********************/
    func useVideo(){
//
      performSegue(withIdentifier: "video_upload", sender: self)
//        if let currentPlayer = getCurrentPlayer() {
////            currentPlayer.memeVideo = "" //not sure what case does
//                self.ref.child("rooms").child(curPin!).child("players").child(currentPlayer.username).updateChildValues(["meme Video":currentPlayer.memeVideo])
//                    cancel()//go to upload meme
//                    //WHEN YOU COME BACK AN TEST, UPLOAD BUTTON IS THE NEXT THING TO WORK ON, IF THERE ARE ANY ERRORS IT MAY BE IN THE PLAYER CLASS WITH THE MEME VIDEO OR MEME PHOTO
//
//        }
    

    
    }
  
  override func viewWillDisappear(_ animated: Bool) {
    NotificationCenter.default.removeObserver(self)
  }
  
    @objc fileprivate func playerItemDidReachEnd(_ notification: Notification) {
        if self.player != nil {
            self.player!.seek(to: kCMTimeZero)
            self.player!.play()
        }
    }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "video_upload" {
      let controller = segue.destination as! RoomViewController
      controller.curPin = curPin //should I keep on passing the current pin
      controller.previewVideo = videoURL!
      controller.mediaType = 2
      controller.pickerGallery = false
      //  controller.pickMeme.setTitle("Change Meme?", for: .normal)
    }
  }
}
