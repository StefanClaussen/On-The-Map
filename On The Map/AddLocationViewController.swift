//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 07/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class AddLocationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var coordinate = CLLocationCoordinate2D()
    
    var studentInformation: StudentInformation {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.studentInformation
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let latitude = Double(coordinate.latitude)
        let longitude = Double(coordinate.longitude)
        coordinatesLabel.text = "Latitude: \(latitude) | Longitude: \(longitude)"
        
        addMapAnnotations()
    }
    @IBAction func findLocationBackButtonPressed(_ sender: Any) {
        
    }
    
    func addMapAnnotations() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    }

    @IBAction func finishAddingLocation(_ sender: Any) {
        // TODO: Handle empty or invalid URL
        guard let mediaURL = urlTextField.text else { return }
        Constants.LoggedInUser.mediaURL = mediaURL
        
        let latitude = Double(self.coordinate.latitude)
        let longitude = Double(self.coordinate.longitude)

        self.studentInformation.GETUser {
            (loggedInStudent) -> Void in
            switch loggedInStudent {
            case .success(let student):
                let addStudent = Student(firstName: student.firstName, lastName: student.lastName, latitude: latitude, longitude: longitude, mediaURL: Constants.LoggedInUser.mediaURL)
                if Constants.CurrentUser.objectId == "" {
                    self.studentInformation.POSTStudentLocation(for: addStudent, completion: self.processStudentObjectIdResult)
                } else {
                    self.studentInformation.PUTStudentLocation(for: addStudent, completion: self.processUpdateStudentLocationResult)
                }
            case .failure(let error):
                print("failed to retrieve the names for the logged in user: \(error)")
                return
            }
        }
    }
    
    // MARK: Helper methods
    
    private func processStudentObjectIdResult(_ objectId: ObjectId) {
        switch objectId {
        case .success(let objectId):
            Constants.CurrentUser.objectId = objectId
            print("Object id: \(Constants.CurrentUser.objectId)")
            exitScene()
        case .failure(ParseError.objectIdNotRetrieved):
            print("ObjectId not created")
        default:
            print("Something went wrong when creating the objectID")
        }
    }
    
    private func processUpdateStudentLocationResult(_ updateStudentLocation: UpdateStudentLocation) {
        switch updateStudentLocation {
        case .success(let date):
            print("Successfully updated student location: \(date)")
            exitScene()
        case .failure(ParseError.studentLocationNotUpdated):
            print("Student location not updated")
        default:
            print("Something went wrong when updating the student location")
        }
    }
    
    private func exitScene() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
