//
//  Functions&Extensions.swift
//  CaptionIT
//
//  Created by Thorpe Center on 11/19/17.
//  Copyright © 2017 Thorpe Center. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

extension Int {
    init(_ range: CountableClosedRange<Int> ) {
        let delta = range.lowerBound < 0 ? abs(range.lowerBound) : 0
        let min = UInt32(range.lowerBound + delta)
        let max = UInt32(range.upperBound + delta)
        self.init(Int(min + arc4random_uniform(max - min)) - delta)
    }}
func generatePIN()->String?{
    let min = Int(pow(Double(10), Double(4))) - 1
    let max = Int(pow(Double(10), Double(5))) - 1
    return String(Int(min...max))
}

extension UIButton {
    
    func pulsate() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 2
        pulse.fromValue = 0.94
        pulse.toValue = 1.0
        pulse.autoreverses = true
        pulse.repeatCount = 0.5
        pulse.initialVelocity = 1.5
        pulse.damping = 4
        layer.add(pulse, forKey: "pulse")
        
    }
}

//change so pins arent called every time
let pin1 = generatePIN()
let pin2 = generatePIN()
let pin3 = generatePIN()
let pin4 = "1234"
var roomsArray:[Room]=[Room(PIN: pin1), Room(PIN: pin2), Room(PIN: pin3),Room(PIN: pin4)]

extension UIImage{
    
    func resizeImageWith(newSize: CGSize) -> UIImage {
        
        let horizontalRatio = newSize.width / size.width
        let verticalRatio = newSize.height / size.height
        
        let ratio = max(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
func getCurrentPlayer () -> Player? {
    var currentPlayer: Player
    let user = Auth.auth().currentUser;
    if (user != nil) {
        if let  name =  user!.email { //CHANGE SO THAT THE CURRENTPLAYER IS INITIALIZED WITH USERNAME THIS MAY BE DONE BY ADDING USERNAME OR NAME TO FIREBASE AUTHENTICATION OR ADDING USERNAME TO DATABASE AND PAIRING IT WITH THE CURRENT USER.
            //Player has to be initialized with the  current players' username
        
            let temporaryString = name.components(separatedBy: "@")
            currentPlayer = Player(temporaryString[0])
            return currentPlayer
        }
      if let name = user?.displayName {
        currentPlayer = Player(name)
        return currentPlayer
      }
    }
    return nil
    
    
}

func getUserId () -> String? {
  let user = Auth.auth().currentUser?.uid;
  return user
  
  
}
extension RoomViewController : UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentInstance.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memeCarousel", for: indexPath) as! MemeCollectionViewCell
         cell.content = contentInstance[indexPath.item]
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let tappedCell = collectionView.cellForItem(at: indexPath) as! MemeCollectionViewCell
        self.previewImage = tappedCell.editorsMemes.image
        self.imageUploaded()
    }
}

extension RoomViewController : UIScrollViewDelegate, UICollectionViewDelegate
{
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    {
        let layout = self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWidthIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)
        
        offset = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: -scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}

/*******White BG for the text ...Reposition it on top*******/
func textToImage(drawText text: NSString, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
    let textColor = UIColor.black
    let textFont = UIFont(name: "Helvetica Neue", size: 30)!

    let scale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(image.size, false, scale)
    
    let textFontAttributes = [
        NSFontAttributeName: textFont,
        NSForegroundColorAttributeName: textColor,
        NSBackgroundColorAttributeName: UIColor.white,
        ] as [String : Any]
    image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))
    
    let rect = CGRect(origin: CGPoint.zero, size: image.size)
    text.draw(in: rect, withAttributes: textFontAttributes)
    
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}

