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
    @IBOutlet weak var findLocationButton: UIButton!
    
    lazy var geocoder = CLGeocoder()
    
    var coordinate = CLLocationCoordinate2D()

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
            // TODO: Handle failure to geocode address error in an alert.
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                coordinate = location.coordinate
    
            } else {
                // Handle error, might be done above.
                //coordinatesLabel.text = "No Matching Location Found"
            }
        }
    }
    
    // MARK: Storyboard
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! AddLocationViewController
        controller.coordinate = self.coordinate
    }
}
