//
//  FindLocationViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 01/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit
import CoreLocation

class FindLocationViewController: UIViewController {

    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var findLocationButton: UIButton!
    
    lazy var geocoder = CLGeocoder()
    
    var studentInformation: StudentInformation {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.studentInformation
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        guard let country = countryTextField.text else { return }
        guard let street = streetTextField.text else { return }
        guard let city = cityTextField.text else { return }
        guard let mediaURL = websiteTextField.text else { return }
        Constants.LoggedInUser.mediaURL = mediaURL
        
        let address = "\(country), \(city), \(street)"
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        // Hide button, so repeat geocode requests cannot be made
        findLocationButton.isHidden = true
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        findLocationButton.isHidden = false
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error)")
            coordinatesLabel.text = "Unable to find location for address"
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                coordinatesLabel.text = "\(coordinate.latitude), \(coordinate.longitude)"
                let latitude = Double(coordinate.latitude)
                let longitude = Double(coordinate.longitude)
                
                studentInformation.GETUser {
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
            } else {
                coordinatesLabel.text = "No Matching Location Found"
            }
        }
    }
}
