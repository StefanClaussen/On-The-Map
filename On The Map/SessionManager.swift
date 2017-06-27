//
//  SessionManager.swift
//  On The Map
//
//  Created by Stefan Claussen on 23/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

struct SessionManager {
    
    let session = URLSession.shared
    
    func POSTSessionFor(email: String, password: String, completion: @escaping (Result<String>) -> Void) {
        let request = UdacityClient.udacityURLRequest
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            let result = self.processSessionRequest(data: data, error: error)
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    func processSessionRequest(data: Data?, error: Error?) -> Result<String> {
        guard let data = data else {
            return .failure(UdacityError.noConnection)
        }
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range)
        
        return UdacityClient.session(fromJSON: newData)
    }
    
    func DELETESession(completion: @escaping (Result<Bool>) -> Void) {
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

}

