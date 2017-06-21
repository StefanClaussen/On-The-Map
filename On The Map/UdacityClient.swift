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
    case unableToLogOff
}

struct UdacityClient {
    
    static var udacityURLRequest: NSMutableURLRequest {
        return createUdacityURLRequest()
    }
    static var udacityUserIDURLRequest: NSMutableURLRequest {
        return createUdacityUserIDURLRequest()
    }
    static var deleteSessionURLRequest: NSMutableURLRequest {
        return createUdacityDELETEURLRequest()
    }
    
    static func session(fromJSON data: Data) -> Result<String> {
        var parsedResult: [String: AnyObject]! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
        } catch {
            return .failure(UdacityError.parsingJSONFailed)
        }
        
        guard
            let account = parsedResult["account"],
            let keyValue = account["key"],
            let value: String = keyValue as? String  else {
                return .failure(UdacityError.accountNotFoundOrInvalidCredentials)
        }
        
        return .success(value)
    }
    
    //TODO: I don't think this should be a student, it should be the currentUser.
    //Student and CurrentUser have different fields. 
    static func student(fromJSON data: Data) -> Result<Student> {
        var parsedResult: [String: Any]! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
        } catch {
            return .failure(UdacityError.parsingJSONFailed)
        }
        
        guard let student = Student(fromJSON: parsedResult) else {
            return .failure(UdacityError.parsingJSONFailed)
        }

        return Result.success(student)
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
    
    private static func createUdacityDELETEURLRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        return request
    }
}
