//
//  TableViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 21/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, Networking, LocationAdding {
    
    var students = [StudentInformation]()
    
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
        getStudentLocations { students in
            if let students = students {
                self.students = students
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func logout(_ sender: Any) {
        deleteSession { (success) in
            if success { self.dismiss(animated: true, completion: nil) }
        }
    }
    
    @IBAction func refreshTable(_ sender: Any) {
        retrieveStudentLocations()
        tableView.reloadData()
    }
    
    @IBAction func addLocation(_ sender: Any) {
        hasNoPreviousLocation { correct in
            if correct { self.performSegue(withIdentifier: "MapToFindLocation", sender: self) }
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
        
        guard let urlToOpen = student.mediaURL else {
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
