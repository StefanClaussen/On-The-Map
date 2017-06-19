//
//  UIViewController+SingleActionAlert.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func createAlertWith(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
