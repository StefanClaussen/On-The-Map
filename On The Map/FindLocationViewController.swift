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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var enterLocationStackView: UIStackView!
    
    private weak var enterLocationStackViewBottomConstraint: NSLayoutConstraint?
    
    lazy var geocoder = CLGeocoder()
    private var locationCoordinates = CLLocationCoordinate2D()
    private var locationName: String?
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    private func configureView() {
        findLocationButton.isEnabled = false
        locationTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        spinner.startAnimating()
        
        guard let country = countryTextField.text else { return }
        guard let city = locationTextField.text else { return }
        
        let address = "\(country), \(city)"
        
        geocoder.geocodeAddressString(address) { [weak self] (placemarks, error) in
            guard let strongSelf = self else { return }
            strongSelf.processResponse(withPlacemarks: placemarks, error: error)
        }
        
        // Disable button to prevent repeated geocoding requests
        findLocationButton.isEnabled = false
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow(_ notification:Notification) {
        guard let keyboardSettings = KeyboardSettings(from: notification) else { return }
        
        let keyboardTop = view.bounds.height - keyboardSettings.height
        
        let stackViewBottom = enterLocationStackView.frame.maxY
        let padding: CGFloat = 10

        guard keyboardTop - padding < stackViewBottom else { return }
        
        let constraint = enterLocationStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -keyboardSettings.height - padding)
        view.addConstraint(constraint)
        enterLocationStackViewBottomConstraint = constraint
        
        UIView.animate(withDuration: keyboardSettings.duration, delay: 0, options: keyboardSettings.options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func keyboardWillHide(_ notification:Notification) {
        guard let keyboardSettings = KeyboardSettings(from: notification),
            let constraint = enterLocationStackViewBottomConstraint else { return }
        view.removeConstraint(constraint)
        
        UIView.animate(withDuration: keyboardSettings.duration, delay: 0, options: keyboardSettings.options, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    private func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    private func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
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
        spinner.stopAnimating()
        
        guard
            error == nil,
            let placemarks = placemarks, placemarks.count > 0,
            let location = placemarks.first?.location,
            let name = placemarks.first?.name else {
                createAlertWith(title: "No Matching Location Found", message: "Try entering the address again.", action: "Okay")
                return
        }
        
        locationCoordinates = location.coordinate
        locationName = name
        performSegue(withIdentifier: "ShowAddLocation", sender: self)
    }
    
    // MARK: - Navigation / Storyboard
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowAddLocation", let viewController = segue.destination as? AddLocationViewController {
            viewController.coordinate = locationCoordinates
            viewController.locationName = locationName
        }
    }
}

// MARK: UITextFieldDelegate
    
extension FindLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
        
}

private struct KeyboardSettings {
    let height: CGFloat
    let duration: Double
    let options: UIViewAnimationOptions
    
    init?(from notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let height = (userInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect)?.height,
            let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? UInt else {
                return nil
        }
        self.height = height
        self.duration = duration
        self.options = UIViewAnimationOptions(rawValue: curve)
    }
}
