//
//  DemoViewController.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 23/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit
import SwiftyGif


class DemoViewController: UIViewController {
  @IBOutlet weak var btnNext: UIButton!
  @IBOutlet weak var btnPrevious: UIButton!
  @IBOutlet weak var mCollectionImages: UICollectionView!
  @IBOutlet weak var btnDone: UIButton!
  @IBOutlet weak var mCaption: UILabel!
  @IBOutlet weak var mPager: UIPageControl!
  var arrImages = [String]()
  var arrNotes = [String]()
  let gifManager = SwiftyGifManager(memoryLimit:10)
  var isCalledOnce = false
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      btnPrevious.alpha = 0.5
      btnPrevious.isEnabled = false
      arrImages = ["pama-tutorial.gif","pama-and-friends.gif","fries.gif","fries.gif","confetti-2.gif"]
      arrNotes = ["Welcome to Caption_it! \n1.Join an existing game or create a new one.","2.Invite your friends to join.","3.Upload your funniest picture or video.","4.Let your friends caption it!", "5.Choose the best caption."]
      
      mPager.numberOfPages = arrImages.count
      mPager.currentPage = 0
      self.btnDone.setTitle("Skip", for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  @IBAction func actionFinish(_ sender: UIButton) {
    AppSetting.isUserLogin = true;
    AppDelegate.sharedDelegate.moveToViewController()
  }
  
  @IBAction func actionBackImage(_ sender: UIButton) {
    var currentIndex = 0
    currentIndex = self.mCollectionImages.indexPathsForVisibleItems.first?.row ?? 0
    
    if sender.tag == 0 {
        currentIndex -= 1
      if currentIndex < 0 {
        return
      }
    } else {
      currentIndex += 1
      if currentIndex >= arrImages.count {
        return
      }
    }
    let indexPath = IndexPath(row: currentIndex, section: 0)
    self.mCollectionImages.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
  }

  
}

extension DemoViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return arrImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DemoCell", for: indexPath) as! DemoCell
    if indexPath.row == 0 && isCalledOnce == false {
      isCalledOnce = true
      let gif = UIImage(gifName: arrImages[indexPath.row])
      cell.image.setGifImage(gif, manager: gifManager, loopCount: -1)
    }
    return cell
  }
  
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    
  }
  
  
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    var visibleRect = CGRect()
    
    visibleRect.origin = mCollectionImages.contentOffset
    visibleRect.size = mCollectionImages.bounds.size
    
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    
    guard let indexPath = mCollectionImages.indexPathForItem(at: visiblePoint) else { return }
    if let cell = mCollectionImages.cellForItem(at: indexPath) as? DemoCell {
      let gif = UIImage(gifName: arrImages[indexPath.row])
      print(indexPath.row)
      cell.image.setGifImage(gif, manager: gifManager, loopCount: -1)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    mPager.currentPage = indexPath.row
    mCaption.text = arrNotes[indexPath.row]
    if indexPath.row == 0 {
      btnPrevious.alpha = 0.5
      btnPrevious.isEnabled = false
    } else {
      btnPrevious.alpha = 1
      btnPrevious.isEnabled = true
    }
    if indexPath.row + 1 == arrImages.count {
      self.btnDone.setTitle("START!", for: .normal)
      self.btnDone.setTitleColor(#colorLiteral(red: 0.05882352963, green: 0.180392161, blue: 0.2470588237, alpha: 1), for: .normal)
      btnNext.alpha = 0.5
      btnNext.isEnabled = false
    } else {
      btnNext.alpha = 1
      btnNext.isEnabled = true
      self.btnDone.setTitle("Skip", for: .normal)
      self.btnDone.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
    }
  }
  
  
}
