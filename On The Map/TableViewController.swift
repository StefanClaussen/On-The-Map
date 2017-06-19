//
//  TableViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 21/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, Networking, StudentDisplaying {
    
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
        getStudentLocations { (students) in
            guard let students = students else {
                self.createAlertWith(title: "Student Locations not found",
                                     message: "Student locations were not returned from the server and therefore cannot be displayed.",
                                     action: "Okay")
                return
            }
            self.students = students
            self.tableView.reloadData()
            
        }
    }
    
    // MARK: - Actions
    
    @IBAction func logout(_ sender: Any) {
        deleteSession { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.createAlertWith(title: "Unable to Log Out",
                                     message: "Try logging out again or closing the app",
                                     action: "Okay")
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
    
}
