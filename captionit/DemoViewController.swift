//
//  DemoViewController.swift
//  CaptionIt
//
//  Created by Mukesh Muteja on 23/04/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import UIKit


class DemoViewController: UIViewController {

  @IBOutlet weak var mCollectionImages: UICollectionView!
  @IBOutlet weak var btnDone: UIButton!
  @IBOutlet weak var mPager: UIPageControl!
  var arrImages = [UIImage]()
  
    override func viewDidLoad() {
        super.viewDidLoad()
      arrImages = [#imageLiteral(resourceName: "premium-badge"),#imageLiteral(resourceName: "trophy")]
      mPager.numberOfPages = arrImages.count
      mPager.currentPage = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  @IBAction func actionFinish(_ sender: UIButton) {
    AppSetting.isUserLogin = true;
    AppDelegate.sharedDelegate.moveToViewController()
  }

}

extension DemoViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return arrImages.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DemoCell", for: indexPath) as! DemoCell
    cell.image.image = arrImages[indexPath.row]
    return cell
  }
  
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    var visibleRect = CGRect()
    
    visibleRect.origin = mCollectionImages.contentOffset
    visibleRect.size = mCollectionImages.bounds.size
    
    let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
    
    guard let indexPath = mCollectionImages.indexPathForItem(at: visiblePoint) else { return }
    mPager.currentPage = indexPath.row
    if indexPath.row + 1 == arrImages.count {
      self.btnDone.isHidden = false
    } else {
      self.btnDone.isHidden = true
    }
  }
}
