//
//  TableViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 21/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, StudentDisplaying {
    
    var studentInformation: StudentInformation {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.studentInformation
    }
    var loginAuthentication = LoginAuthentication()
    var students = [Student]()
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveStudentLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        retrieveStudentLocations()
    }
    
    // MARK: - StudentLocations
    
    func retrieveStudentLocations() {
        studentInformation.GETStudentLocation {
            (studentsResult) -> Void in
            
            switch studentsResult {
            case let .success(students):
                self.students = students
                self.tableView.reloadData()
            case .failure:
                let title = "Student Locations not found"
                let message = "Student locations were not returned from the server and therefore cannot be displayed."
                self.createAlertWith(title: title, message: message, action: "Okay")
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func logout(_ sender: Any) {
        loginAuthentication.DELETESession {
            (logoutResult) in
            switch logoutResult {
            case .success:
                print("Successfully logged out")
                self.dismiss(animated: true, completion: nil)
            case .failure:
                print("Failed to logout")
            }
        }
    }
    
    @IBAction func refreshTable(_ sender: Any) {
        retrieveStudentLocations()
        tableView.reloadData()
    }
    
    @IBAction func addLocation(_ sender: Any) {
        self.confirmLocationAdd { confirmed in
            if confirmed { self.performSegue(withIdentifier: "MapToFindLocation", sender: self) }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        cell.imageView?.image = #imageLiteral(resourceName: "icon_pin")
        
        let student = students[indexPath.row]
        cell.textLabel?.text = student.firstName + " " + student.lastName
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let student = students[indexPath.row]
        
        guard let urlString = student.mediaURL, let urlToOpen = URL(string: urlString) else {
            createAlertWith(title: "No URL to Open", message: "Student did not add a URL.", action: "Okay")
            return
        }
        
        if UIApplication.shared.canOpenURL(urlToOpen) {
            UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
        } else {
            createAlertWith(title: "Invalid URL", message: "Student did not add a valid URL.", action: "Okay" )
        }
    }
    
    // MARK: - Helper Methods
    
    func createAlertWith(title: String, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}
