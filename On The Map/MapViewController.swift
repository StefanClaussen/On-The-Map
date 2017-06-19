//
//  MapViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, Networking, StudentDisplaying, MKMapViewDelegate {
    
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
        getStudentLocations { (students) in
            guard let students = students else {
                self.createAlertWith(title: "Student Locations not found",
                                     message: "Student locations were not returned from the server and therefore cannot be displayed.",
                                     action: "Okay")
                return
            }
            self.addMapAnnotations(for: students)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func logout(_ sender: Any) {
        deleteSession { (success) in
            if success {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.createAlertWith(title: "Unable to Log Out",
                                     message: "Try logging out again or closing the app",
                                     action: "Okay")
            }
        }
    }
    
    @IBAction func refreshMap(_ sender: Any) {
        retrieveStudentLocations()
    }
    
    @IBAction func addLocation(_ sender: Any) {
        self.confirmLocationAdd { confirmed in
            if confirmed { self.performSegue(withIdentifier: "MapToFindLocation", sender: self) }
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
        let lat = CLLocationDegrees(student.latitude!)
        let long = CLLocationDegrees(student.longitude!)
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "\(student.firstName) \(student.lastName)"
        annotation.subtitle = student.mediaURL
        
        return annotation
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
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
