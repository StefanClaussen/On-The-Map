//
//  MapViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: ParentViewController, StudentDisplaying, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addLocationButton: UIBarButtonItem!
    
//    var studentInformation: StudentInformation {
//        let delegate = UIApplication.shared.delegate as! AppDelegate
//        return delegate.studentInformation
//    }
//    
//    var loginAuthentication = LoginAuthentication()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMapAnnotations(for: students)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        addMapAnnotations(for: students)
    }
    
    // TODO: still need to call addMapAnnotations somehow.
//    func retrieveStudentsLocations() {
//        studentInformation.GETStudentLocation {
//            (studentsResult) -> Void in
//            
//            switch studentsResult {
//            case let .success(students):
//                self.addMapAnnotations(for: students)
//            case .failure:
//                self.showAlertGETStudentLocationFailed()
//            }
//        }
//    }
    
    @IBAction func logout(_ sender: Any) {
        loginAuthentication.DELETESession {
            (logoutResult) in
            switch logoutResult {
            case .success:
                print("Successfully logged out")
                self.dismiss(animated: true, completion: nil)
            case .failure:
                print("Failed to logout")
            }
        }
    }
    
    @IBAction func refreshMap(_ sender: Any) {
        retrieveStudentsLocations()
    }
    
    @IBAction func addLocation(_ sender: Any) {
        self.confirmLocationAdd { confirmed in
            if confirmed { self.segueToMap() }
        }
     }
    
    func segueToMap() {
        self.performSegue(withIdentifier: "MapToFindLocation", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapToFindLocation" {
            
        }
    }
        
    func addMapAnnotations(for students: [Student]) {
        
        var annotations = [MKPointAnnotation]()
        
        for student in students {
            let lat = CLLocationDegrees(student.latitude!)
            let long = CLLocationDegrees(student.longitude!)

            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)

            let first = student.firstName
            let last = student.lastName
            let mediaURL = student.mediaURL

            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
//    func showAlertGETStudentLocationFailed() {
//        let title = "Student Locations not found"
//        let message = "Student locations were not returned from the server and therefore cannot be displayed."
//        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
//
//    }
    
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
