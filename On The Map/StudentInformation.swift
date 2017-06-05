//
//  StudentInformation.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

enum StudentResult {
    case success([Student])
    case failure(Error)
}

struct StudentInformation {
    let session = URLSession.shared
    
    func GETStudentLocation(completion: @escaping (StudentResult) -> Void) {
        let request = ParseClient.parseURLRequest
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            let results = self.processStudentLocationRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(results)
            }
        }
        task.resume()
    }
    
    func processStudentLocationRequest(data: Data?, error: Error?) -> StudentResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return ParseClient.students(fromJSON: jsonData)
    }
    
    func GETUser() {
        let request = UdacityClient.udacityUserIDURLRequest
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            self.processUserRequest(data: data, error: error)
        }
        task.resume()
    }
    
    func processUserRequest(data: Data?, error: Error?) {
        guard let data = data else {
            print("No data was returned by the request")
            return
        }
        
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range)
        
        var parsedResult: [String: AnyObject]! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as! [String: AnyObject]
        } catch {
            print("Could not parse the data as JSON: '\(data)'")
        }
        
        guard
            let user = parsedResult["user"],
            let lastName = user["last_name"],
            let firstName = user["first_name"] else {
                print("Can not get value out of dictionary")
                return
        }
        
        Constants.LoggedInUser.firstName = firstName as! String
        Constants.LoggedInUser.lastName = lastName as! String
        
        
        print("Last name: \(Constants.LoggedInUser.lastName))")
        print("First name: \(Constants.LoggedInUser.firstName))")
    }
    
    func POSTStudentLocation(for student: Student) {
        let request = ParseClient.parsePOSTURLRequest

        
        request.httpBody = "{\"uniqueKey\": \"1234\", \"firstName\": \"\(Constants.LoggedInUser.firstName)\", \"lastName\": \"\(Constants.LoggedInUser.lastName)\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"https://udacity.com\",\"latitude\": \(student.latitude), \"longitude\": \(student.longitude)}".data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil { // Handle error…
                print("Unable to post student location")
                return
            }
            print("Posting student: \(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)")
        }
        task.resume()
    }
    
}
