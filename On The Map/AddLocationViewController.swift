//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 07/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

// TODO: Take out text field delegate method to protocol extension
// TODO: Handle an invalid URL / ensure url is valid

import UIKit
import CoreLocation
import MapKit

class AddLocationViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var coordinate = CLLocationCoordinate2D()
    var locationName: String?
    
    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    private func configureView() {
        addButton.isEnabled = false
        urlTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        addMapAnnotation()
    }
    
    // MARK: - Map and Annotation
    
    private func addMapAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        
        focusMap(on: coordinate)
    }
    
    private func focusMap(on coordinate: CLLocationCoordinate2D) {
        let metres: CLLocationDistance = 10000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate, metres, metres)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    // MARK: - Actions

    @IBAction func finishAddingLocation(_ sender: Any) {
        activityIndicator.startAnimating()
        
        guard let mediaURL = urlTextField.text, let name = locationName else { return }
        
        NetworkingManager.GETUser { [weak self] (loggedInStudent) -> Void in
            // guard retains self as strong, thus strongSelf
            guard let strongSelf = self else { return }
            switch loggedInStudent {
            case .success(let student):
                Constants.LoggedInUser.firstName = student.firstName
                Constants.LoggedInUser.lastName = student.lastName
                Constants.LoggedInUser.mapString = name
                Constants.LoggedInUser.mediaURL = mediaURL
                Constants.LoggedInUser.latitude = Double(strongSelf.coordinate.latitude)
                Constants.LoggedInUser.longitude = Double(strongSelf.coordinate.longitude)
                
                if Constants.CurrentUser.objectId == "" {
                    NetworkingManager.POSTStudentLocation(completion: strongSelf.processStudentObjectIdResult)
                } else {
                    NetworkingManager.PUTStudentLocation(completion: strongSelf.processUpdateStudentLocationResult)
                }
            case .failure(let error):
                // Single line example - see how self is an optional, instead of using strongSelf
                self?.activityIndicator.stopAnimating()
                print("Failed to retrieve the names for the logged in user: \(error)")
                strongSelf.unableToAddLocationAlert()
                return
            }
        }
    }
    
    // MARK: Helper methods
    
    func editingChanged(_ textField: UITextField) {
        guard let urlString = urlTextField.text, !urlString.isEmpty else {
            addButton.isEnabled = false
            return
        }
        
        addButton.isEnabled = true
    }
    
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
        activityIndicator.stopAnimating()
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
    
    private func unableToAddLocationAlert() {
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
