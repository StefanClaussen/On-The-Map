//
//  Constants.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation
    
struct Constants {
    
    // MARK: Udacity's Parse Server
    struct Parse {
        static let baseURLString = "https://parse.udacity.com/parse/classes/StudentLocation"
        
        struct ParameterKeys {
            static let ApplicationID = "X-Parse-Application-Id"
            static let ApiKey = "X-Parse-REST-API-Key"
        }
        
        struct ParameterValues {
            static let ApplicationID =  "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        }
    }
    
    // MARK: Udacity's Server
    struct Udacity {
        static let signUpPage = "https://www.udacity.com/account/auth#!/signup"
        
        struct ParameterKeys {
            static let Accept = "Accept"
        }
    }
    
    // MARK: Parameters
    
    struct ParameterKeys {
        static let ContentType = "Content-Type"
    }
    
    struct ParameterValues {
        static let ApplicationJSON =  "application/json"
    }
    
    // MARK: Login data
    struct LoggedInUser {
        static var firstName = ""
        static var lastName = ""
        // Stores the unique key created when logging in
        static var uniqueKey = ""
        static var mediaURL = ""
        static var latitude: Double = 0
        static var longitude: Double = 0
    }
    
    // MARK: CurrentUser {
    struct CurrentUser {
        static var objectId = ""
        
        static var hasSetLocation: Bool {
            return self.objectId != ""
        }
    }
    
}

