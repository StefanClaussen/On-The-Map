//  StudentInformation.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

enum Result<Value> {
    case success(Value)
    case failure(Error)
}

//enum StudentsResult {
//    case success([Student])
//    case failure(Error)
//}
//
//enum LoggedInStudent {
//    case success(Student)
//    case failure(Error)
//}
//
//enum ObjectId {
//    case success(String)
//    case failure(Error)
//}

// TODO: Simplify or remove enum. 
// String value is never used.
// Enum represents that their location has been updated or not.     
//enum UpdateStudentLocation {
//    case success(String)
//    case failure(Error)
//}

struct StudentInformation {
    let session = URLSession.shared
    
    func GETStudentLocation(completion: @escaping (Result<[Student]>) -> Void) {
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
    
    func processGETStudentLocationRequest(data: Data?, error: Error?) -> Result<[Student]> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return ParseClient.students(fromJSON: jsonData)
    }
    
    func GETStudent(completion: @escaping (Result<Student>) -> Void) {
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
    
    func processUserRequest(data: Data?, error: Error?) -> Result<Student> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        let range = Range(5..<jsonData.count)
        let newData = jsonData.subdata(in: range)
        
        return UdacityClient.student(fromJSON: newData)
    }
    
    func POSTStudentLocation(for student: Student, completion: @escaping (Result<String>) -> Void) {
        let request = ParseClient.parsePOSTURLRequest
        
        let latitude = student.coordinate.latitude
        let longitude = student.coordinate.longitude
        
        //TODO: can this be moved out to the Parse client?
        request.httpBody = "{\"uniqueKey\": \"\(Constants.LoggedInUser.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"\(Constants.LoggedInUser.mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            let objectId = self.processPOSTStudentLocationRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(objectId)
            }
        }
        task.resume()
    }
    
    func processPOSTStudentLocationRequest(data: Data?, error: Error?) -> Result<String> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        if let error = error {
            print("Unable to post student location")
            return .failure(error)
        }

        return ParseClient.objectId(fromJSON: jsonData)
    }
    
    func PUTStudentLocation(for student: Student, completion: @escaping (Result<Bool>) -> Void) {
        let request = ParseClient.parsePUTURLRequest
        
        let latitude = student.coordinate.latitude
        let longitude = student.coordinate.longitude         
        //TODO: can this be moved out to the Parse client?
        request.httpBody = "{\"uniqueKey\": \"\(Constants.LoggedInUser.uniqueKey)\", \"firstName\": \"\(student.firstName)\", \"lastName\": \"\(student.lastName)\",\"mapString\": \"Mountain View, CA\", \"mediaURL\": \"\(Constants.LoggedInUser.mediaURL)\",\"latitude\": \(latitude), \"longitude\": \(longitude)}".data(using: .utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
        task.resume()
    }
    
}
