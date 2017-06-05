//
//  UdacityClient.swift
//  On The Map
//
//  Created by Stefan Claussen on 04/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

enum UdacityError: Error {
    case accountNotFoundOrInvalidCredentials
    case noConnection
    case uniqueKeyNotCreated
    case parsingJSONFailed
}

struct UdacityClient {
    
    static var udacityURLRequest: NSMutableURLRequest {
        return createUdacityURLRequest()
    }
    static var udacityUserIDURLRequest: NSMutableURLRequest {
        return createUdacityUserIDURLRequest()
    }
    
    static func session(fromJSON data: Data) -> LoginResult {
        var parsedResult: [String: AnyObject]! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
        } catch {
            print("could not parse the data as JSON: '\(data)'")
            return .failure(UdacityError.parsingJSONFailed)
        }
        
        guard
            let account = parsedResult["account"],
            let keyValue = account["key"],
            let value: String = keyValue as? String  else {
                print("Failed to create the unique key")
                return .failure(UdacityError.uniqueKeyNotCreated)
        }
        
        return .success(value)
    }
    
    // MARK: - Private Methods
    
    private static func createUdacityURLRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string:  Constants.Udacity.baseURLString)!)
        request.httpMethod = Constants.Udacity.Methods.Post
        request.addValue(Constants.ParameterValues.ApplicationJSON, forHTTPHeaderField: Constants.Udacity.ParameterKeys.Accept)
        request.addValue(Constants.ParameterValues.ApplicationJSON, forHTTPHeaderField: Constants.ParameterKeys.ContentType)
        
        return request
    }
    
    private static func createUdacityUserIDURLRequest() -> NSMutableURLRequest {
        // "https://www.udacity.com/api/users/3903878747"
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/\(Constants.LoggedInUser.uniqueKey)")!)
        return request
    }
}
