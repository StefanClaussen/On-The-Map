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
}

extension Networking {
    
    // GET studentLocation is the API Naming
    // It returns students and their locations
    func getStudentLocations(completion: @escaping ([Student]?) -> Void) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let studentInformation = delegate.studentInformation
        studentInformation.GETStudentLocation {
            (studentsResult) in
            
            switch studentsResult {
            case let .success(students):
                completion(students)
            case .failure:
                completion(nil)
            }
        }
    }
}
