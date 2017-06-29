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

    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIBarButtonItem!
    
    lazy var geocoder = CLGeocoder()
    var locationCoordinates = CLLocationCoordinate2D()
    var locationName: String?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    func configureView() {
        findLocationButton.isEnabled = false
        locationTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        guard let country = countryTextField.text else { return }
        guard let city = locationTextField.text else { return }
        
        let address = "\(country), \(city)"
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        
        // Disable button to prevent repeated geocoding requests
        findLocationButton.isEnabled = false
    }
    
    // MARK: - Helper methods
    
    func editingChanged(_ textField: UITextField) {
        guard let location = locationTextField.text, !location.isEmpty else {
            findLocationButton.isEnabled = false
            return
        }
        
        findLocationButton.isEnabled = true
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        findLocationButton.isEnabled = true
        
        if error != nil {
            createAlertWith(title: "No Matching Location Found", message: "Try entering the address again.", action: "Okay")
        } else {
            var location: CLLocation?
            var name: String?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
                name = placemarks.first?.name
            }
            
            guard let _location = location, let _name = name else {
                createAlertWith(title: "No Matching Location Found", message: "Try entering the address again.", action: "Okay")
                return
            }
            
            locationCoordinates = _location.coordinate
            locationName = _name
            displayAddLocationVC()
        }
    }
    
    // MARK: - Navigation / Storyboard
    
    private func displayAddLocationVC() {
        let addLocationVC = storyboard?.instantiateViewController(withIdentifier: "AddLocationViewController") as! AddLocationViewController
        addLocationVC.coordinate = locationCoordinates
        addLocationVC.locationName = locationName
        self.navigationController?.pushViewController(addLocationVC, animated: true)
    }
}

// MARK: UITextFieldDelegate
    
    extension FindLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
        
}
