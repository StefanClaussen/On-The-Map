//
//  Networking.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//
// TODO: Add weak references inside the closures

import Foundation
import UIKit

protocol Networking { }

extension Networking where Self: UIViewController {
    
    func presentStudentLocationsNotFoundAlert() {
        let alert = UIAlertController(title: "Student Locations not found",
                                      message: "Connection to the server could not be made. Check your wifi availability and other settings that might prevent a connection.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteSession(completion: @escaping (Bool) -> Void) {
        let sessionManager = SessionManager()
        
        sessionManager.DELETESession { (logoutResult) in
            switch logoutResult {
            case .success:
                completion(true)
            case .failure:
                let alert = UIAlertController(title: "Unable to Log Out",
                                              message: "Connection to the server could not be made. Check your wifi availability and other settings that might prevent a connection.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                self.present(alert, animated: true) { action in
                    completion(false)
                }
            }
        }
    }
}

