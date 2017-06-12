//
//  MapViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var studentInformation: StudentInformation {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.studentInformation
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        retrieveStudentsLocations()
    }
    
    func retrieveStudentsLocations() {
        studentInformation.GETStudentLocation {
            (studentsResult) -> Void in
            
            switch studentsResult {
            case let .success(students):
                print("Student count is: \(students.count)")
                self.addMapAnnotations(for: students)
            case .failure:
                self.showAlertGETStudentLocationFailed()
            }
        }
    }
    
    @IBAction func addLocation(_ sender: Any) {
//        if Constants.CurrentUser.objectId == "" {
//            displayFindLocationVC()
//        } else {
            let title = "Student has a location"
            let message = "\(Constants.LoggedInUser.firstName) \(Constants.LoggedInUser.lastName) has posted a student location. Would you like to overwrite the existing location?"
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Overwrite", style: .default   ) {
                action in
                self.displayFindLocationVC()
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true, completion: (displayFindLocationVC))
        //}
    }
    
    func displayFindLocationVC() {
        let findLocationVC = storyboard?.instantiateViewController(withIdentifier: "FindLocation") as! FindLocationViewController
        present(findLocationVC, animated: true, completion: nil)
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
    
    func showAlertGETStudentLocationFailed() {
        let title = "Student Locations not found"
        let message = "Student locations were not returned from the server and therefore cannot be displayed."
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)

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
