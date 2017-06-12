//
//  StudentInformation.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

enum StudentsResult {
    case success([Student])
    case failure(Error)
}

enum LoggedInStudent {
    case success(Student)
    case failure(Error)
}

enum StudentResult {
    case success(String)
    case failure(Error)
}

struct StudentInformation {
    let session = URLSession.shared
    
    func GETStudentLocation(completion: @escaping (StudentsResult) -> Void) {
        let request = ParseClient.parseURLRequest
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            let results = self.processGETStudentLocationRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(results)
            }
        }
        task.resume()
    }
    
    func processGETStudentLocationRequest(data: Data?, error: Error?) -> StudentsResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return ParseClient.students(fromJSON: jsonData)
    }
    
    func GETUser(completion: @escaping (LoggedInStudent) -> Void) {
        let request = UdacityClient.udacityUserIDURLRequest
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            let loggedInStudent = self.processUserRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(loggedInStudent)
            }
        }
        task.resume()
    }
    
    func processUserRequest(data: Data?, error: Error?) -> LoggedInStudent {
        guard let jsonData = data else {
            return .failure(error!)
        }
        let range = Range(5..<jsonData.count)
        let newData = jsonData.subdata(in: range)
        
        return UdacityClient.student(fromJSON: newData)
    }
    
    func POSTStudentLocation(for student: Student) {
        let request = ParseClient.parsePOSTURLRequest
        
        guard let latitude = student.latitude, let longitude = student.longitude else {
            return
        }
        
        request.httpBody = "{\"uniqueKey\": \"\(Constants.LoggedInUser.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"\(Constants.LoggedInUser.mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: String.Encoding.utf8)
        
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
    
    func processPOSTStudentLocationRequest(data: Data?, error: Error?) -> StudentResult {
        guard let jsonData = data else {
            return StudentResult.failure(error!)
        }
        return ParseClient.student(fromJSON: jsonData)
    }
    
}
