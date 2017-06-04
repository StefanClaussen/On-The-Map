//
//  AddLocationViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 01/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit
import CoreLocation

class AddLocationViewController: UIViewController {

    @IBOutlet weak var streetTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var websiteTextField: UITextField!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var addLocationButton: UIButton!
    
    lazy var geocoder = CLGeocoder()
    
    var studentInformation: StudentInformation {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.studentInformation
    }

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addLocation(_ sender: Any) {
        guard let country = countryTextField.text else { return }
        guard let street = streetTextField.text else { return }
        guard let city = cityTextField.text else { return }
        
        let address = "\(country), \(city), \(street)"
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        
        addLocationButton.isHidden = true
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        addLocationButton.isHidden = false
        
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
                let student = Student(firstName: "Bob", lastName: "Barker", latitude: latitude, longitude: longitude, mediaURL: "udacity.com")
                studentInformation.POSTStudentLocation(for: student)
            } else {
                coordinatesLabel.text = "No Matching Location Found"
            }
        }
    }
}