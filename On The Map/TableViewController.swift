//
//  TableViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 21/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, Networking, LocationAdding {
    
    fileprivate let studentDataSource = StudentDataSource.shared
    
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
        studentDataSource.fetchStudentLocations { [weak self] (result) in
            guard let strongSelf = self else { return }

            switch result {
            case .success:
                strongSelf.tableView.reloadData()
            case .failure:
                strongSelf.presentStudentLocationsNotFoundAlert()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func logout(_ sender: Any) {
        deleteSession { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func refreshTable(_ sender: Any) {
        retrieveStudentLocations()
        tableView.reloadData()
    }
    
    @IBAction func addLocation(_ sender: Any) {
        hasNoPreviousLocation { correct in
            if correct {
                self.performSegue(withIdentifier: "MapToFindLocation", sender: self)
            }
        }
    }
    
}

// MARK: - Table view data source
    
extension TableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentDataSource.studentData.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        cell.imageView?.image = #imageLiteral(resourceName: "icon_pin")
        
        let student = studentDataSource.studentData[indexPath.row]
        cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension TableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let student = studentDataSource.studentData[indexPath.row]
        
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
