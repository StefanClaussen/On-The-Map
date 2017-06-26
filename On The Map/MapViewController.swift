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

    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveStudentLocations()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        retrieveStudentLocations()
    }
    
    // MARK: - StudentLocations
    
    func retrieveStudentLocations() {
        getStudentLocations { students in
            if let students = students {
                self.addMapAnnotations(for: students)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func logout(_ sender: Any) {
        deleteSession { (success) in
            if success { self.dismiss(animated: true, completion: nil) }
        }
    }
    
    @IBAction func refreshMap(_ sender: Any) {
        retrieveStudentLocations()
    }
    
    @IBAction func addLocation(_ sender: Any) {
        hasNoPreviousLocation { correct in
            if correct { self.performSegue(withIdentifier: "MapToFindLocation", sender: self) }
        }
    }
    
    // MARK: - Map annotations
        
    func addMapAnnotations(for students: [Student]) {
        var annotations = [MKPointAnnotation]()
        for student in students {
            let annotation = createAnnotation(for: student)
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    func createAnnotation(for student: Student) -> MKPointAnnotation {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = student.coordinate
        annotation.title = "\(student.firstName) \(student.lastName)"
        //TODO: check if absolute URL is correct use. 
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
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            }
        }
    }
}
