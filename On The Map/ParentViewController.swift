//
//  ParentViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 18/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

class ParentViewController: UIViewController {

    var studentInformation: StudentInformation {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.studentInformation
    }
    
    var loginAuthentication = LoginAuthentication()
    var students = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveStudentsLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        retrieveStudentsLocations()
    }
    
    func retrieveStudentsLocations() {
        studentInformation.GETStudentLocation {
            (studentsResult) -> Void in
            
            switch studentsResult {
            case let .success(students):
                self.students = students
            case .failure:
                self.showAlertGETStudentLocationFailed()
            }
        }
    }
    
    func showAlertGETStudentLocationFailed() {
        let title = "Student Locations not found"
        let message = "Student locations were not returned from the server and therefore cannot be displayed."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }

}
