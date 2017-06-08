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

    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    
    lazy var geocoder = CLGeocoder()
    var locationCoordinates = CLLocationCoordinate2D()

    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        guard let country = countryTextField.text else { return }
        guard let city = cityTextField.text else { return }
        
        let address = "\(country), \(city)"
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        print("Coordinate value: \(locationCoordinates)")
        // Hide button to prevent repeated geocoding requests
        findLocationButton.isHidden = true
        
        let addLocationVC = storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") as! AddLocationViewController
        addLocationVC.coordinate = locationCoordinates
        navigationController?.pushViewController(addLocationVC, animated: true)
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
            
            if let unwrappedLocation = location {
                let coordinate = unwrappedLocation.coordinate
                locationCoordinates = coordinate
                print("locationCoordinates: \(locationCoordinates)")
            } else {
                // Handle error, might be done above.
                print("No Matching Location Found")
            }
        }
    }
    
//    // MARK: Storyboard
//    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let controller = segue.destination as! AddLocationViewController
//        controller.coordinate = locationCoordinates
//        print("locationCoordinates in segue: \(locationCoordinates)")
//    }
}
