//
//  MapViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, Networking, LocationAdding {
    
    fileprivate let reuseId = "pin"
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private let studentDataSource = StudentDataSource.shared

    // MARK: - View lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mapView.removeAnnotations(mapView.annotations)
        retrieveStudentLocations()
    }
    
    // MARK: - StudentLocations
    
    func retrieveStudentLocations() {
        activityIndicator.startAnimating()
        studentDataSource.fetchStudentLocations { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.activityIndicator.stopAnimating()
            switch result {
            case .success:
                strongSelf.addMapAnnotations(for: strongSelf.studentDataSource.studentData)
            case .failure:
                strongSelf.presentStudentLocationsNotFoundAlert()
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func logout(_ sender: Any) {
        deleteSession { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func refreshMap(_ sender: Any) {
        mapView.removeAnnotations(mapView.annotations)
        retrieveStudentLocations()
    }
    
    @IBAction func addLocation(_ sender: Any) {
        hasNoPreviousLocation { correct in
            if correct {
                self.performSegue(withIdentifier: "MapToFindLocation", sender: self)
            }
        }
    }
    
    // MARK: - Map annotations
        
    func addMapAnnotations(for students: [StudentInformation]) {
        var annotations = [MKPointAnnotation]()
        for student in students {
            let annotation = createAnnotation(for: student)
            annotations.append(annotation)
        }
        mapView.addAnnotations(annotations)
    }
    
    func createAnnotation(for student: StudentInformation) -> MKPointAnnotation {
        
        let annotation = MKPointAnnotation()
        if let coordinate = student.coordinate {
            annotation.coordinate = coordinate
        }
        annotation.title = "\(student.firstName) \(student.lastName)"
        annotation.subtitle = student.mediaURL?.absoluteString
        
        return annotation
    }
    
}

// MARK: - MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if let pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView {
            pinView.annotation = annotation
            return pinView
        }
        
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView.canShowCallout = true
        pinView.pinTintColor = .red
        pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // TODO: make this a guard
        if control == view.rightCalloutAccessoryView {
            guard let urlString = view.annotation?.subtitle!, let urlToOpen = URL(string: urlString) else {
                createAlertWith(title: "No URL to Open", message: "Student did not add a URL.", action: "Okay")
                return
            }
            
            if UIApplication.shared.canOpenURL(urlToOpen) {
                UIApplication.shared.open(urlToOpen, options: [:], completionHandler: nil)
            } else {
                createAlertWith(title: "Invalid URL", message: "Student did not add a valid URL.", action: "Okay" )
            }
        }
    }
    
}
