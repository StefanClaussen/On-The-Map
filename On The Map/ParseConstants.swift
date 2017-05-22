//
//  ParseConstants.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

extension ParseAPI {
    
    struct Constants {
        static let baseURLString = "https://parse.udacity.com/parse/classes/StudentLocation"
        
        struct ParseParameterKeys {
            static let ParseApplicationID = "X-Parse-Application-Id"
            static let ApiKey = "X-Parse-REST-API-Key"
        }
        
        struct ParseParameterValues {
            static let ApplicationID =  "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
            static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        }
    }
}
