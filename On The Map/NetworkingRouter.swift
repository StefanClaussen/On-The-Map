//  NetworkingRouter.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

struct NetworkingRouter {
    let session = URLSession.shared
    
    // GETs multiple student locations
    func GETStudentLocation(completion: @escaping (Result<[StudentInformation]>) -> Void) {
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
    
    func processGETStudentLocationRequest(data: Data?, error: Error?) -> Result<[StudentInformation]> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return ParseClient.students(fromJSON: jsonData)
    }
    
    func GETUser(completion: @escaping (Result<StudentInformation>) -> Void) {
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
    
    func processUserRequest(data: Data?, error: Error?) -> Result<StudentInformation> {
        guard let jsonData = data else {
            return .failure(error!)
        }
        
        let range = Range(5..<jsonData.count)
        let newData = jsonData.subdata(in: range)
        
        return UdacityClient.student(fromJSON: newData)
    }
    
    func POSTStudentLocation(completion: @escaping (Result<String>) -> Void) {
        let request = ParseClient.parsePOSTURLRequest
        
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
            return .failure(error)
        }

        return ParseClient.objectId(fromJSON: jsonData)
    }
    
    func PUTStudentLocation(completion: @escaping (Result<Bool>) -> Void) {
        let request = ParseClient.parsePUTURLRequest
        
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
