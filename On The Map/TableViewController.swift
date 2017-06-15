//
//  TableViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 21/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    var studentInformation: StudentInformation {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.studentInformation
    }
    var students = [Student]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentInformation.GETStudentLocation {
            (studentsResult) -> Void in
            
            switch studentsResult {
            case let .success(students):
                self.students = students
                print("List Controller: Successful found \(self.students.count) students.")
                self.tableView.reloadData()
            case let .failure(error):
                print("Error getting studentLocation: \(error)")
            }
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
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        detailController.meme = memes[indexPath.row]
        navigationController!.pushViewController(detailController, animated: true)
    }
}
