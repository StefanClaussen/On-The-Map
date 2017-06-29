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

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var coordinate = CLLocationCoordinate2D()
    var locationName: String?
    
    var networkingManager: NetworkingManager {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.networkingManager    }
    
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
        activityIndicator.startAnimating()
        
        // TODO: Handle empty or invalid URL
        guard let mediaURL = urlTextField.text, let name = locationName else { return }
        
        self.networkingManager.GETUser {
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
                    self.networkingManager.POSTStudentLocation(completion: self.processStudentObjectIdResult)
                } else {
                    self.networkingManager.PUTStudentLocation(completion: self.processUpdateStudentLocationResult)
                }
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                print("Failed to retrieve the names for the logged in user: \(error)")
                self.unableToAddLocationAlert()
                return
            }
        }
    }
    
    // MARK: Helper methods
    
    private func processStudentObjectIdResult(_ result: Result<String>) {
        self.activityIndicator.stopAnimating()
        switch result {
        case .success(let objectId):
            Constants.CurrentUser.objectId = objectId
            exitScene()
        case .failure(ParseError.objectIdNotRetrieved):
            print("ObjectId not created")
            unableToAddLocationAlert()
        default:
            print("Something went wrong when posting the student location")
            unableToAddLocationAlert()
        }
    }
    
    private func processUpdateStudentLocationResult(_ result: Result<Bool>) {
        self.activityIndicator.stopAnimating()
        switch result {
        case .success(let boolValue):
            print("Successfully updated student location: \(boolValue)")
            exitScene()
        case .failure(ParseError.studentLocationNotUpdated):
            print("Student location not updated")
            unableToAddLocationAlert()
        default:
            print("Something went wrong when updating the student location")
            unableToAddLocationAlert()
        }
    }
    
    func unableToAddLocationAlert() {
        createAlertWith(title: "Unable to Add Location", message: "Location could not be added. Check your internet connection. Alternatively the server may be unavailable.", action: "Okay")
    }
    
    // MARK: - Navigation and Storyboard
    
    private func exitScene() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
    
// MARK: - UITextFieldDelegate
    
extension AddLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
