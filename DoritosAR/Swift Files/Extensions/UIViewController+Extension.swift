//
//  UIViewController+Extension.swift
//  Patron PoC
//
//  Created by Brad Chessin on 5/14/19.
//  Copyright © 2019 Brad Chessin. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
}
