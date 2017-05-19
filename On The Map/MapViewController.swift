//
//  MapViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {
    
    var studentInformation: StudentInformation!

    override func viewDidLoad() {
        super.viewDidLoad()

        studentInformation.getStudentLocation {
            (studentsResult) -> Void in
            
            switch studentsResult {
            case let .success(students):
                print("Successful found \(students.count) students.")
            case let .failure(error):
                print("Error getting studentLocation: \(error)")
            }
        }
    }
}
