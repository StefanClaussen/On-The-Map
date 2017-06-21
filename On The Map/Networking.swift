//
//  Networking.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation
import UIKit

protocol Networking {
    func getStudentLocations(completion: @escaping ([Student]?) -> Void)
    //TODO: Change this to currentUser idea
   // func getStudent(completion: @escaping (Student?) -> Void)
    func deleteSession(completion: @escaping (Bool) -> Void)
}

extension Networking {
    
    // GET studentLocation is the name in API
    // Request returns students and their locations
    func getStudentLocations(completion: @escaping ([Student]?) -> Void) {
        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        delegate.studentInformation.GETStudentLocation {
            (studentsResult) in
            
            switch studentsResult {
            case let .success(students):
                completion(students)
            case .failure:
                let alert = UIAlertController(title: "Student Locations not found",
                                              message: "Connection to the server could not be made. Check your wifi availability and other settings that might prevent a connection.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                if let controller = self as? UIViewController {
                    controller.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
//    // GETStudentLocation/{UniqueKey: Value}
//    // Request returns the student matching the unique key
//    func getStudent(completion: @escaping (Student?) -> Void) {
//        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
//        delegate.studentInformation.GETStudent {
//            (result) -> Void in
//            switch result {
//            case .success(let student):
//                completion(student)
//            case .failure(let error):
//                print("failed to create a user: \(error)")
//                return
//            }
//        }
//    }
    
    func deleteSession(completion: @escaping (Bool) -> Void) {
        let loginAuthentication = LoginAuthentication()
        
        loginAuthentication.DELETESession {
            (logoutResult) in
            
            switch logoutResult {
            case .success:
                completion(true)
            case .failure:
                let alert = UIAlertController(title: "Unable to Log Out",
                                              message: "Connection to the server could not be made. Check your wifi availability and other settings that might prevent a connection.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                
                if let controller = self as? UIViewController {
                    controller.present(alert, animated: true) { action in
                        completion(false)
                    }
                }
            }
        }
    }
}

