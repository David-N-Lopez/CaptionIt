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
  
    override func viewDidLoad() {
        super.viewDidLoad()
      btnPrevious.alpha = 0.5
      btnPrevious.isEnabled = false
      arrImages = ["pama-tutorial.gif","pama-and-friends.gif","fries.gif","fries.gif","pama-tutorial.gif"]
      arrNotes = ["Join an existing game or create a new one.","invite your friends to join.","upload your funniest picture or video.","caption it!", "choose the best caption."]
      
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

extension DemoViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return arrImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DemoCell", for: indexPath) as! DemoCell
    let gif = UIImage(gifName: arrImages[indexPath.row])
    cell.image.setGifImage(gif, manager: gifManager, loopCount: -1)
    
//    cell.image.image = arrImages[indexPath.row]
    return cell
  }
  
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    
  }
  
  
  
//  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//    var visibleRect = CGRect()
//
//    visibleRect.origin = mCollectionImages.contentOffset
//    visibleRect.size = mCollectionImages.bounds.size
//
//    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
//
//    guard let indexPath = mCollectionImages.indexPathForItem(at: visiblePoint) else { return }
//    mPager.currentPage = indexPath.row
//    if indexPath.row == 0 {
//      btnPrevious.alpha = 0.5
//      btnPrevious.isEnabled = false
//    }
//    if indexPath.row + 1 == arrImages.count {
//      self.btnDone.setTitle("Done", for: .normal)
//      btnNext.alpha = 0.5
//      btnNext.isEnabled = false
//    } else {
//      self.btnDone.setTitle("Skip", for: .normal)
//    }
//  }
  
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
      self.btnDone.setTitle("LET'S START!", for: .normal)
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
