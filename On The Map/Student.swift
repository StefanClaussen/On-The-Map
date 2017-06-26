//
//  Student.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation
import CoreLocation

struct Student {
    //let createdAt: String
    let firstName: String
    let lastName: String
    var coordinate: CLLocationCoordinate2D
    var mapString: String
    var mediaURL: URL?
//    let objectID: String
//    let uniqueKey: Float
//    let updatedAt: String
    
    init?(fromJSON json: [String: Any]) {
        guard
            let firstName = json["firstName"] as? String,
            let lastName = json["lastName"] as? String,
            let latitude = json["latitude"] as? Double,
            let longitude = json["longitude"] as? Double,
            let mapString = json["mapString"] as? String,
            let mediaPath = json["mediaURL"] as? String
            else {
                return nil
        }
        self.firstName = firstName
        self.lastName = lastName
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.mapString = mapString
        self.mediaURL = URL(string: mediaPath)
    }
}
