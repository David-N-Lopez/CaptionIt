//
//  RoomViewController.swift
//  CaptionIt
//
//  Created by liuting chen on 12/1/17.
//  Copyright © 2017 Tower Org. All rights reserved.
//

import UIKit
import AVKit

class RoomViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var myImageView: UIImageView!
    
    var curPin:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let picker = UIImagePickerController()
        picker.delegate = self // delegate added
//        let newImage = textToImage(drawText: "This is a meme", inImage: #imageLiteral(resourceName: "meme"), atPoint: CGPoint(x: 20, y:20))
//        myImageView.image = newImage
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func selectPhotoButtonTapped(_ sender: UIButton) {
        
        let myPickerController = UIImagePickerController()
        myPickerController.delegate = self;
        myPickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        let alert = UIAlertController(title: "Where do you want to get your meme from?", message: "You can take footage rn or grab some from your cameraroll, you decide.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "CameraRoll", style: .default, handler: { action in
            self.present(myPickerController, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Take Video or Pics RN", style: .default, handler: { action in
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SwiftyCam" {
            let controller = segue.destination as! camController
            controller.curPin = curPin
        }
    }
    @IBAction func unwindSegueToMemePicker(_ sender:UIStoryboardSegue) { }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
