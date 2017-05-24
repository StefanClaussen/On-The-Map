//
//  ParseClient.swift
//  On The Map
//
//  Created by Stefan Claussen on 17/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

// TODO: This is now Parse and Udacity API.

enum ParseError: Error {
    case invalidJSONData
    case accountNotFoundOrInvalidCredentials
    case noConnection
}

struct ParseAPI {
    
    static var parseURLRequest: NSMutableURLRequest {
        return createParseURLRequest()
    }
    
    static var udacityURLRequest: NSMutableURLRequest {
        return createUdacityURLRequest()
    }
    
    static func session(fromJSON data: Data) -> LoginResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let jsonDictionary = jsonObject as? [AnyHashable:Any],
                let _ = jsonDictionary["error"] as? String {
                return .failure(ParseError.accountNotFoundOrInvalidCredentials)
            } else {
                return .success
            }
        } catch {
            return .failure(ParseError.invalidJSONData)
        }
    }
    
    static func students(fromJSON data: Data) -> StudentResult {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            guard
                let jsonDictionary = jsonObject as? [AnyHashable:Any],
                let studentsArray =  jsonDictionary["results"] as? [[String: Any]] else {
                    return .failure(ParseError.invalidJSONData)
            }
            
            var finalStudents = [Student]()
            
            for studentJSON in studentsArray {
                if let student = student(fromJSON: studentJSON) {
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
    
    private static func student(fromJSON json: [String:Any]) -> Student? {
        guard
            let firstName = json["firstName"] as? String,
            let lastName = json["lastName"] as? String 
        else {
            return nil
        }
        
        return Student(firstName: firstName, lastName: lastName)
    }
    
    private static func createParseURLRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: Constants.Parse.baseURLString)!) // "https://parse.udacity.com/parse/classes/StudentLocation"
        request.addValue(Constants.Parse.ParameterValues.ApplicationID, forHTTPHeaderField: Constants.Parse.ParameterKeys.ApplicationID)
        request.addValue(Constants.Parse.ParameterValues.ApiKey, forHTTPHeaderField: Constants.Parse.ParameterKeys.ApiKey)
        
        return request
    }
    
    private static func createUdacityURLRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: Constants.Udacity.baseURLString)!)
        request.httpMethod = Constants.Udacity.Methods.Post
        request.addValue(Constants.Udacity.ParameterValues.ApplicationJSON, forHTTPHeaderField: Constants.Udacity.ParameterKeys.Accept)
        request.addValue(Constants.Udacity.ParameterValues.ApplicationJSON, forHTTPHeaderField: Constants.Udacity.ParameterKeys.ContentType)
        
        return request
    }
    

}
