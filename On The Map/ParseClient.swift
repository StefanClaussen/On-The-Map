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
    
    static func objectId(fromJSON data: Data) -> ObjectId {
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
    
    static func updateStudentLocation(fromJSON data: Data) -> UpdateStudentLocation {
        var parsedResult: [String: AnyObject]! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
        } catch {
            return .failure(ParseError.parsingJSONFailed)
        }
        
        guard let updateDate = parsedResult["updatedAt"] as? String else {
            return .failure(ParseError.studentLocationNotUpdated)
        }
        return .success(updateDate)
    }
    
    static func students(fromJSON data: Data) -> StudentsResult {
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
            let lastName = json["lastName"] as? String,
            let latitude = json["latitude"] as? Double,
            let longitude = json["longitude"] as? Double,
            let mediaURL = json["mediaURL"] as? String
        else {
            return nil
        }
        
        return Student(firstName: firstName, lastName: lastName, latitude: latitude, longitude: longitude, mediaURL: mediaURL)
    }
    
    private static func createParseURLRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        
        request.addApplicationIdAndApiKey()
        
        return request
    }
    
    private static func createParsePOSTURLRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?")!)
        
        request.addApplicationIdApiKeyAndContentType()
        
        request.httpMethod = "POST"

        return request
    }
    
    private static func createPUTURLRequest() -> NSMutableURLRequest {
        let urlString = "https://parse.udacity.com/parse/classes/StudentLocation?/\(Constants.CurrentUser.objectId)"
        
        let request = NSMutableURLRequest(url: URL(string: urlString)!)
        request.addApplicationIdApiKeyAndContentType()
        
        request.httpMethod = "PUT"
        
        return request
    }

}
