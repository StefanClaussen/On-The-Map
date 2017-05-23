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
}

struct ParseAPI {
    
    static var mutableURLRequest: NSMutableURLRequest {
        return createURLRequest()
    }
    
    static func session(fromJSON data: Data) -> LoginResult {
        do {
            try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return .success
        } catch let error {
            return .failure(error)
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
    
    private static func createURLRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: Constants.baseURLString)!)
        request.addValue(Constants.ParseParameterValues.ApplicationID, forHTTPHeaderField: Constants.ParseParameterKeys.ParseApplicationID)
        request.addValue(Constants.ParseParameterValues.ApiKey, forHTTPHeaderField: Constants.ParseParameterValues.ApiKey)
        return request
    }
}
