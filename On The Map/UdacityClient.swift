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
        return createUdacityURLRequest(for: .post)
    }
    static var udacityUserIDURLRequest: NSMutableURLRequest {
        return createUdacityURLRequest(for: .get)
    }
    static var deleteSessionURLRequest: NSMutableURLRequest {
        return createUdacityURLRequest(for: .delete)
    }
    
    static func session(fromJSON data: Data) -> Result<String> {
        var parsedResult: [String: AnyObject]
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
    
    static func studentInformation(fromJSON data: Data) -> Result<StudentInformation> {
        var parsedResult: [String: Any]
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
        } catch {
            return .failure(UdacityError.parsingJSONFailed)
        }
        
        guard let user = parsedResult["user"] as? [String: AnyObject], let student = StudentInformation(fromUser: user) else {
                return .failure(UdacityError.parsingJSONFailed)
        }

        return Result.success(student)
    }
    
    // MARK: - Private Methods
    
    private static func createUdacityURLRequest(for method: HTTPMethod) -> NSMutableURLRequest {
        let baseURL = "https://www.udacity.com"
        let sessionString = "\(baseURL)/api/session"
        let uniqueKeyString = "\(baseURL)/api/users/\(Constants.LoggedInUser.uniqueKey)"
        
        let urlString = method != .get ? sessionString : uniqueKeyString
        let request = NSMutableURLRequest(url: URL(string:  urlString)!)
        
        request.httpMethod = method.rawValue
        
        if method == .post {
            request.addValue(Constants.ParameterValues.ApplicationJSON, forHTTPHeaderField: Constants.Udacity.ParameterKeys.Accept)
            request.addValue(Constants.ParameterValues.ApplicationJSON, forHTTPHeaderField: Constants.ParameterKeys.ContentType)
        }
        
        return request
    }
    
}
