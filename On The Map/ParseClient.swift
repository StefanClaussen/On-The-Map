//
//  ParseClient.swift
//  On The Map
//
//  Created by Stefan Claussen on 17/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

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
        let parsedResult: [String: AnyObject]
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
        let jsonObject: [String: Any]
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: Any]
        } catch let error {
            return .failure(error)
        }
        guard
            let studentsArray =  jsonObject["results"] as? [[String: Any]] else {
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
    }
    
    private static func createParseURLRequest(for method: HTTPMethod) -> NSMutableURLRequest {
        var urlString: String
        
        let baseURL = "https://parse.udacity.com"
        let studentLocationPath = "\(baseURL)/parse/classes/StudentLocation"
        
        switch method {
        case .get: urlString = "\(studentLocationPath)?limit=100&order=-updatedAt"
        case .put: urlString = "\(studentLocationPath)/\(Constants.CurrentUser.objectId)"
        default: urlString = studentLocationPath
        }
        
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        
        request.httpMethod = method.rawValue
        
        request.addValue(Constants.Parse.ParameterValues.ApplicationID, forHTTPHeaderField: Constants.Parse.ParameterKeys.ApplicationID)
        request.addValue(Constants.Parse.ParameterValues.ApiKey, forHTTPHeaderField: Constants.Parse.ParameterKeys.ApiKey)
        
        guard method == .post || method == .put else { return request }
        
        request.addValue(Constants.ParameterValues.ApplicationJSON, forHTTPHeaderField: Constants.ParameterKeys.ContentType)
        
        let body: [String: Any] = [
            "uniqueKey": Constants.LoggedInUser.uniqueKey,
            "firstName": Constants.LoggedInUser.firstName,
            "mediaURL": Constants.LoggedInUser.mediaURL,
            "latitude": Constants.LoggedInUser.latitude,
            "longitude": Constants.LoggedInUser.longitude
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)

        return request
    }
    
}

enum ParseError: Error {
    case invalidJSONData
    case parsingJSONFailed
    case objectIdNotRetrieved
    case studentLocationNotUpdated
}

