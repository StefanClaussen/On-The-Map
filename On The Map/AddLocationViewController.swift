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
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var coordinate = CLLocationCoordinate2D()
    var locationName: String?
    
    var studentInformation: StudentInformation {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.studentInformation
    }
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Location"
        
        addMapAnnotation()
    }
    
    // MARK: - Map and Annotation
    
    func addMapAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        
        focusMap(on: coordinate)
    }
    
    func focusMap(on coordinate: CLLocationCoordinate2D) {
        let metres: CLLocationDistance = 10000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, metres, metres)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    // MARK: - Actions

    @IBAction func finishAddingLocation(_ sender: Any) {
        // TODO: Handle empty or invalid URL
        guard let mediaURL = urlTextField.text, let name = locationName else { return }
        print("Location name: \(name)")
        
        self.studentInformation.GETUser {
            (loggedInStudent) -> Void in
            switch loggedInStudent {
            case .success(let student):
                Constants.LoggedInUser.firstName = student.firstName
                Constants.LoggedInUser.lastName = student.lastName
                Constants.LoggedInUser.mapString = name
                Constants.LoggedInUser.mediaURL = mediaURL
                Constants.LoggedInUser.latitude = Double(self.coordinate.latitude)
                Constants.LoggedInUser.longitude = Double(self.coordinate.longitude)
                
                if Constants.CurrentUser.objectId == "" {
                    self.studentInformation.POSTStudentLocation(completion: self.processStudentObjectIdResult)
                } else {
                    self.studentInformation.PUTStudentLocation(completion: self.processUpdateStudentLocationResult)
                }
            case .failure(let error):
                print("Failed to retrieve the names for the logged in user: \(error)")
                return
            }
        }
    }
    
    // MARK: Helper methods
    
    private func processStudentObjectIdResult(_ result: Result<String>) {
        switch result {
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
    
    private func processUpdateStudentLocationResult(_ result: Result<Bool>) {
        switch result {
        case .success(let date):
            print("Successfully updated student location: \(date)")
            exitScene()
        case .failure(ParseError.studentLocationNotUpdated):
            print("Student location not updated")
        default:
            print("Something went wrong when updating the student location")
        }
    }
    
    // MARK: - Navigation and Storyboard
    
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
