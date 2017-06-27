//
//  ParseClient.swift
//  On The Map
//
//  Created by Stefan Claussen on 17/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

enum ParseError: Error {
    case invalidJSONData
    case parsingJSONFailed
    case objectIdNotRetrieved
    case studentLocationNotUpdated
}

struct ParseClient {
    
    static var parseURLRequest: NSMutableURLRequest {
        return createParseURLRequest(for: .get)
    }
    
    static var parsePOSTURLRequest: NSMutableURLRequest {
        return createParseURLRequest(for: .post)
    }
    
    static var parsePUTURLRequest: NSMutableURLRequest {
        return createParseURLRequest(for: .put)
    }
    
    // objectId is used as the identifying parameter when PUTting a student location
    // https://parse.udacity.com/parse/classes/StudentLocation/<objectId>
    static func objectId(fromJSON data: Data) -> Result<String> {
        var parsedResult: [String: AnyObject]! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
        } catch {
            return .failure(ParseError.parsingJSONFailed)
        }
        
        guard let objectID = parsedResult["objectId"] as? String else {
            return .failure(ParseError.objectIdNotRetrieved)
        }
        
        return .success(objectID)
    }
    
    static func students(fromJSON data: Data) -> Result<[StudentInformation]> {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard
                let jsonDictionary = jsonObject as? [AnyHashable:Any],
                let studentsArray =  jsonDictionary["results"] as? [[String: Any]] else {
                    return .failure(ParseError.invalidJSONData)
            }
            
            var finalStudents = [StudentInformation]()
            
            for studentJSON in studentsArray {
                if let student = StudentInformation(fromJSON: studentJSON) {
                    finalStudents.append(student)
                }
            }
            
            if finalStudents.isEmpty && !studentsArray.isEmpty {
                return .failure(ParseError.invalidJSONData)
            }
            return .success(finalStudents)
        } catch let error {
            return .failure(error)
        }
        
    }
    
    private static func createParseURLRequest(for method: HTTPMethod) -> NSMutableURLRequest {
        var urlString: String
        
        switch method {
        case .get: urlString = "https://parse.udacity.com/parse/classes/StudentLocation?limit=100&order=-updatedAt"
        case .put: urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(Constants.CurrentUser.objectId)"
        default: urlString = "https://parse.udacity.com/parse/classes/StudentLocation"
        }
        
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = method.rawValue
        
        request.addValue(Constants.Parse.ParameterValues.ApplicationID, forHTTPHeaderField: Constants.Parse.ParameterKeys.ApplicationID)
        request.addValue(Constants.Parse.ParameterValues.ApiKey, forHTTPHeaderField: Constants.Parse.ParameterKeys.ApiKey)
        
        if method == .post || method == .put {
            request.addValue(Constants.ParameterValues.ApplicationJSON, forHTTPHeaderField: Constants.ParameterKeys.ContentType)
            request.httpBody = "{\"uniqueKey\": \"\(Constants.LoggedInUser.uniqueKey)\", \"firstName\": \"\(Constants.LoggedInUser.firstName)\", \"lastName\": \"\(Constants.LoggedInUser.lastName)\",\"mapString\": \"\(Constants.LoggedInUser.mapString)\", \"mediaURL\": \"\(Constants.LoggedInUser.mediaURL)\",\"latitude\": \(Constants.LoggedInUser.latitude), \"longitude\": \(Constants.LoggedInUser.longitude)}".data(using: .utf8)
        }
        
        return request
    }
    
}
