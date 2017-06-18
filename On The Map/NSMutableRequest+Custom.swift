//
//  NSMutableRequest+Custom.swift
//  On The Map
//
//  Created by Stefan Claussen on 18/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

extension NSMutableURLRequest {
    
    func addApplicationIdAndApiKey() {
        self.addValue(Constants.Parse.ParameterValues.ApplicationID, forHTTPHeaderField: Constants.Parse.ParameterKeys.ApplicationID)
        self.addValue(Constants.Parse.ParameterValues.ApiKey, forHTTPHeaderField: Constants.Parse.ParameterKeys.ApiKey)
    }
    
    func addApplicationIdApiKeyAndContentType() {
        self.addApplicationIdAndApiKey()
        self.addValue(Constants.ParameterValues.ApplicationJSON, forHTTPHeaderField: Constants.ParameterKeys.ContentType)
    }
}
