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
    let min = Int(pow(Double(10), Double(3))) - 1
    let max = Int(pow(Double(10), Double(4))) - 1
    return String(Int(min...max))
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
        if let  name =  user!.email{ //CHANGE SO THAT THE CURRENTPLAYER IS INITIALIZED WITH USERNAME THIS MAY BE DONE BY ADDING USERNAME OR NAME TO FIREBASE AUTHENTICATION OR ADDING USERNAME TO DATABASE AND PAIRING IT WITH THE CURRENT USER.
            //Player has to be initialized with the  current players' username
        
            let temporaryString = name.components(separatedBy: "@")
            currentPlayer = Player(temporaryString[0])
            return currentPlayer
        }
    }
    return nil
    
}

