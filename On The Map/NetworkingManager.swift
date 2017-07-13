//  NetworkingManager.swift
//  On The Map
//
//  Created by Stefan Claussen on 19/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

enum NetworkingError: Error {
    case unknown
}

struct NetworkingManager {
    
    static private let session = URLSession.shared
    
    static func GETStudentLocation(completion: @escaping (Result<[StudentInformation]>) -> Void) {
        let request = ParseClient.parseURLRequest
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            // static methods do not have self. Hence no weak and strong work.
            let results = processGETStudentLocationRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(results)
            }
        }
        task.resume()
    }
    
    static func processGETStudentLocationRequest(data: Data?, error: Error?) -> Result<[StudentInformation]> {
        guard let jsonData = data else {
            return .failure(error ?? NetworkingError.unknown)
        }
        return ParseClient.students(fromJSON: jsonData)
    }
    
    static func GETUser(completion: @escaping (Result<StudentInformation>) -> Void) {
        let request = UdacityClient.udacityUserIDURLRequest
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let loggedInStudent = processUserRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(loggedInStudent)
            }
        }
        task.resume()
    }
    
    static func processUserRequest(data: Data?, error: Error?) -> Result<StudentInformation> {
        guard let jsonData = data else {
            return .failure(error ?? NetworkingError.unknown)
        }
        
        let range = Range(5..<jsonData.count)
        let newData = jsonData.subdata(in: range)
        
        return UdacityClient.studentInformation(fromJSON: newData)
    }
    
    static func POSTStudentLocation(completion: @escaping (Result<String>) -> Void) {
        let request = ParseClient.parsePOSTURLRequest
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            let objectId = processPOSTStudentLocationRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(objectId)
            }
        }
        task.resume()
    }
    
    static func processPOSTStudentLocationRequest(data: Data?, error: Error?) -> Result<String> {
        guard let jsonData = data else {
            return .failure(error ?? NetworkingError.unknown)
        }
        
        if let error = error {
            return .failure(error)
        }

        return ParseClient.objectId(fromJSON: jsonData)
    }
    
    static func PUTStudentLocation(completion: @escaping (Result<Bool>) -> Void) {
        let request = ParseClient.parsePUTURLRequest
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
        task.resume()
    }
    
    // MARK: Session methods
    
    static func POSTSessionFor(email: String, password: String, completion: @escaping (Result<String>) -> Void) {
        let request = UdacityClient.udacityURLRequest
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            let result = processSessionRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    static func DELETESession(completion: @escaping (Result<Bool>) -> Void) {
        let request = UdacityClient.deleteSessionURLRequest
        
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            OperationQueue.main.addOperation {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        }
        task.resume()
    }
    
    static private func processSessionRequest(data: Data?, error: Error?) -> Result<String> {
        guard let data = data else {
            return .failure(UdacityError.noConnection)
        }
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range)
        
        return UdacityClient.session(fromJSON: newData)
    }
    
}
