//
//  LocationAdding.swift
//  On The Map
//
//  Created by Stefan Claussen on 18/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation
import UIKit

protocol LocationAdding {
    func hasNoPreviousLocation(completion: @escaping (Bool) -> Void)
}

extension LocationAdding where Self: UIViewController {
    
    func hasNoPreviousLocation(completion: @escaping (Bool) -> Void) {
        //TODO: Pass in current user
        if !Constants.CurrentUser.hasSetLocation {
            completion(true)
        } else {
            let title = "Student has a location"
            let message = "\(Constants.LoggedInUser.firstName) \(Constants.LoggedInUser.lastName) has posted a student location. Would you like to overwrite the existing location?"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Overwrite", style: .default) {
                action in
                completion(true)
            })
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { action in completion(false) })
            
            present(alert, animated: true, completion: nil)
        }
    }
    
}
