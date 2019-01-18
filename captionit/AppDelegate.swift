
//  AppDelegate.swift
//  CaptionIt
//
//  Created by Math Lab on 11/6/17.
//  Copyright © 2017 Tower Org. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import UserNotifications
import Firebase
import FirebaseInstanceID
import FirebaseMessaging
import Fabric
import Crashlytics
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    var window: UIWindow?
  var backgroundUpdateTask: UIBackgroundTaskIdentifier = 0

  class var sharedDelegate:AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }
  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override   for customization after application launch.
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
      IQKeyboardManager.sharedManager().enable = true
      if #available(iOS 10.0, *) {
        // For iOS 10 display notification (sent via APNS)
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: {_, _ in })
        // For iOS 10 data message (sent via FCM
        Messaging.messaging().delegate = self
      } else {
        let settings: UIUserNotificationSettings =
          UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
        application.registerUserNotificationSettings(settings)
      }
      Messaging.messaging().isAutoInitEnabled = true
      application.registerForRemoteNotifications()
      if AppSetting.isUserLogin == false {
        moveToDemoScreen(index: 0)
      } else {
        moveToViewController()
      }
        application.isStatusBarHidden = true
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
  
  func moveToViewController() {
    if Auth.auth().currentUser?.uid != nil {
      ref.child("Users").child(Auth.auth().currentUser!.uid).child("username").observeSingleEvent(of: .value, with: { (snapshot) in
        
        if (snapshot.value as? String) != nil {
//          self.moveToEnterRoom(index: 0)
        } else {
          let storyboard = UIStoryboard(name: "Main", bundle: nil)
          let viewController = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
          viewController.type = .Facebook
          let navigationController = UINavigationController.init(rootViewController: viewController)
          navigationController.navigationBar.isHidden = true
          let appdelegate = UIApplication.shared.delegate as! AppDelegate
          appdelegate.window?.rootViewController = navigationController
        }
      })
    } else {
      moveToLoginRoom(index: 0)
    }
  }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
      self.backgroundUpdateTask = UIApplication.shared.beginBackgroundTask(expirationHandler: {
        self.endBackgroundUpdateTask()
      })
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

  func endBackgroundUpdateTask() {
    UIApplication.shared.endBackgroundTask(self.backgroundUpdateTask)
    self.backgroundUpdateTask = UIBackgroundTaskInvalid
  }
  
  func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
  }
  
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
      self.endBackgroundUpdateTask()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
      Group.singleton.removeUserFromGame()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
  
  func application(received remoteMessage: MessagingRemoteMessage) {
    print(remoteMessage.appData)
  }
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    let token = Messaging.messaging().fcmToken
    print("FCM token: \(token ?? "")")
    Group.singleton.token = token ?? ""
    if let id = getUserId() {
      ref.child("Users").child(id).child("token").setValue(token)
    }
  }
  
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken as Data
  }
  
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
  {
    //Handle the notification
    let userInformation = notification.request.content.userInfo
    print(userInformation)
    if let type = userInformation["notification_type"] as? String {
      if type == "Join_Game" {
        completionHandler(
          [UNNotificationPresentationOptions.alert,
           UNNotificationPresentationOptions.sound,
           UNNotificationPresentationOptions.badge])
      }
    }
  }
  
  func moveToEnterRoom(index : Int) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let productListVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
    let navigationController = UINavigationController.init(rootViewController: productListVC)
    navigationController.navigationBar.isHidden = true
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    appdelegate.window?.rootViewController = navigationController
  }
  
  func moveToDemoScreen(index : Int) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let productListVC = storyboard.instantiateViewController(withIdentifier: "DemoViewController") as! DemoViewController
    let navigationController = UINavigationController.init(rootViewController: productListVC)
    navigationController.navigationBar.isHidden = true
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    appdelegate.window?.rootViewController = navigationController
  }

  func moveToLoginRoom(index : Int) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let productListVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
    let navigationController = UINavigationController.init(rootViewController: productListVC)
    navigationController.navigationBar.isHidden = true
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    appdelegate.window?.rootViewController = navigationController
  }

}

