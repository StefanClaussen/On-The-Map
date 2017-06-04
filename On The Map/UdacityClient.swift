//
//  UdacityClient.swift
//  On The Map
//
//  Created by Stefan Claussen on 04/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

enum UdacityError: Error {
    case invalidJSONData
    case accountNotFoundOrInvalidCredentials
    case noConnection
}

struct UdacityClient {
    
    static var udacityURLRequest: NSMutableURLRequest {
        return createUdacityURLRequest()
    }
    
    static func session(fromJSON data: Data) -> LoginResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let jsonDictionary = jsonObject as? [AnyHashable:Any],
                let _ = jsonDictionary["error"] as? String {
                return .failure(UdacityError.accountNotFoundOrInvalidCredentials)
            } else {
                return .success
            }
        } catch {
            return .failure(UdacityError.invalidJSONData)
        }
    }
    
    // MARK: - Private Methods
    
    private static func createUdacityURLRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string:  Constants.Udacity.baseURLString)!)
        request.httpMethod = Constants.Udacity.Methods.Post
        request.addValue(Constants.ParameterValues.ApplicationJSON, forHTTPHeaderField: Constants.Udacity.ParameterKeys.Accept)
        request.addValue(Constants.ParameterValues.ApplicationJSON, forHTTPHeaderField: Constants.ParameterKeys.ContentType)
        
        return request
    }
}
