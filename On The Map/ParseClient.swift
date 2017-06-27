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
        return createParseURLRequest()
    }
    
    static var parsePOSTURLRequest: NSMutableURLRequest {
        return createParsePOSTURLRequest() 
    }
    
    static var parsePUTURLRequest: NSMutableURLRequest {
        return createPUTURLRequest()
    }
    
    // MARK: - JSON data parsing
    
    // Parse the data
    // objectId is retrieved
    // objectId is used as the identifying parameter when PUTting a student location
    // PUTting - Student with existing location. Location updates.
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
    
    // MARK: - MutableURLRequests
    
    private static func createParseURLRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        
        request.addApplicationIdAndApiKey()
        
        return request
    }
    
    private static func createParsePOSTURLRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        
        request.addApplicationIdApiKeyAndContentType()
        
        request.httpMethod = "POST"
        
        request.httpBody = "{\"uniqueKey\": \"\(Constants.LoggedInUser.uniqueKey)\", \"firstName\": \"\(Constants.LoggedInUser.firstName)\", \"lastName\": \"\(Constants.LoggedInUser.lastName)\",\"mapString\": \"\(Constants.LoggedInUser.mapString)\", \"mediaURL\": \"\(Constants.LoggedInUser.mediaURL)\",\"latitude\": \(Constants.LoggedInUser.latitude), \"longitude\": \(Constants.LoggedInUser.longitude)}".data(using: .utf8)

        return request
    }
    
    private static func createPUTURLRequest() -> NSMutableURLRequest {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation/\(Constants.CurrentUser.objectId)"
        
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.addApplicationIdApiKeyAndContentType()
        
        request.httpMethod = "PUT"
        
        request.httpBody = "{\"uniqueKey\": \"\(Constants.LoggedInUser.uniqueKey)\", \"firstName\": \"\(Constants.LoggedInUser.firstName)\", \"lastName\": \"\(Constants.LoggedInUser.lastName)\",\"mapString\": \"\(Constants.LoggedInUser.mapString)\", \"mediaURL\": \"\(Constants.LoggedInUser.mediaURL)\",\"latitude\": \(Constants.LoggedInUser.latitude), \"longitude\": \(Constants.LoggedInUser.longitude)}".data(using: .utf8)
        
        return request
    }

}
