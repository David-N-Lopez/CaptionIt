//
//  Extension.swift
//  CaptionIt
//
//  Created by KMSOFT on 03/02/18.
//  Copyright © 2018 Tower Org. All rights reserved.
//

import Foundation
import SVProgressHUD

extension UIViewController {
    func showProgressHUD() {
        SVProgressHUD.show()
    }
    
    func dismissProgressHUD() {
        SVProgressHUD.dismiss()
    }
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { action in
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true) {
        }
    }
}
