//
//  PushNotificationManager.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 18/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import Foundation
import Alamofire

class PushNotificationManager {
static let serverKey = "AAAAPpcDbrI:APA91bGDDdaV4ZkEMDfMzJEm6kiRI3zFIlVWyfT0wLMyho3eEULUA4k7pAOlZdZYyFQA4Bq2mP3HvwnhCLvjYOR0phZkRI24DHSJin2p3cQ7E-xIsRQK6jmdeV4L7lGpKY4isGzTygcF"
  static func sendNotificationToDevice(deviceToken: String, gameID: String, taskMessage: String) {
    
    // setup alamofire url
    let fcmURL = "https://fcm.googleapis.com/fcm/send"
    
    // add application/json and add authorization key
    let parameters: Parameters = [
      "to": "\(deviceToken)",
      "priority": "high",
      "notification": [
        "title": taskMessage,
        "content_available": true,
        "sound": "default"
      ],
      "data": [
        "gameID": "\(gameID)",
        "notification_type": "Game_Status"
      ]
    ]
    let headers: HTTPHeaders = [
      "Content-Type": "application/json",
      "Authorization": "key=\(serverKey)"
    ]
    
    Alamofire.request(fcmURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
      .responseJSON { response in
        print("Completed Notification")
        print(response.request as Any)  // original URL request
        print(response.response as Any) // URL response
        print(response.result.value as Any)   // result of response serialization
    }    }
}
