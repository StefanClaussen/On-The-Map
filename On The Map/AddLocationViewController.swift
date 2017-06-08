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
        
        print("Coordinates are: \(coordinate)")
        
        let latitude = Double(coordinate.latitude)
        let longitude = Double(coordinate.longitude)
        coordinatesLabel.text = "Latitude: \(latitude) | Longitude: \(longitude)"
        
        addMapAnnotations()
    }

    @IBAction func finishAddingLocation(_ sender: Any) {
        // Handle URL
        guard let mediaURL = urlTextField.text else { return }
        Constants.LoggedInUser.mediaURL = mediaURL
        
        dismiss(animated: true) {
            let latitude = Double(self.coordinate.latitude)
            let longitude = Double(self.coordinate.longitude)
            
            self.studentInformation.GETUser {
                (loggedInStudent) -> Void in
                switch loggedInStudent {
                case .success(let student):
                    let addStudent = Student(firstName: student.firstName, lastName: student.lastName, latitude: latitude, longitude: longitude, mediaURL: Constants.LoggedInUser.mediaURL)
                    self.studentInformation.POSTStudentLocation(for: addStudent)
                case .failure(let error):
                    print("failed to retrieve the names for the logged in user: \(error)")
                    return
                }
            }
        }
    }
    
    func addMapAnnotations() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
    }

}
