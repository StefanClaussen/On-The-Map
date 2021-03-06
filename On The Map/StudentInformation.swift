//
//  StudentInformation.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation
import CoreLocation

struct StudentInformation {
    let firstName: String
    let lastName: String
    var coordinate: CLLocationCoordinate2D?
    var mediaURL: URL?
    
    init?(fromJSON json: [String: Any]) {
        guard
            let firstName = json["firstName"] as? String,
            let lastName = json["lastName"] as? String,
            let latitude = json["latitude"] as? Double,
            let longitude = json["longitude"] as? Double,
            let mediaPath = json["mediaURL"] as? String
            else {
                return nil
        }
        self.firstName = firstName
        self.lastName = lastName
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        self.mediaURL = URL(string: mediaPath)
    }
    
    init?(fromUser user: [String: AnyObject]) {
        guard let firstName = user["first_name"] as? String, let lastName = user["last_name"] as? String else {
                return nil
        }
        self.firstName = firstName
        self.lastName = lastName
    }
}
