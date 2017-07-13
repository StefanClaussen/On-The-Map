//
//  Networking.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation
import UIKit

protocol Networking { }

extension Networking where Self: UIViewController {
    
    func presentStudentLocationsNotFoundAlert() {
        let alert = UIAlertController(title: "Student Locations not found",
                                      message: "Connection to the server could not be made. Check your wifi availability and other settings that might prevent a connection.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func deleteSession(completion: @escaping (Bool) -> Void) {
        NetworkingManager.DELETESession { [weak self] (logoutResult) in
            guard let strongSelf = self else { return }
            switch logoutResult {
            case .success:
                completion(true)
            case .failure:
                let alert = UIAlertController(title: "Unable to Log Out",
                                              message: "Connection to the server could not be made. Check your wifi availability and other settings that might prevent a connection.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                strongSelf.present(alert, animated: true) { action in
                    completion(false)
                }
            }
        }
    }
}

