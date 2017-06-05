//
//  LoginAuthentication.swift
//  On The Map
//
//  Created by Stefan Claussen on 23/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

enum LoginResult {
    case success(String)
    case failure(Error)
}

struct LoginAuthentication {
    
    let session = URLSession.shared
    
    func POSTSessionFor(email: String, password: String, completion: @escaping (LoginResult) -> Void) {
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
    
    func processSessionRequest(data: Data?, error: Error?) -> LoginResult {
        guard let data = data else {
            return .failure(UdacityError.noConnection)
        }
        let range = Range(5..<data.count)
        let newData = data.subdata(in: range)
        
        return UdacityClient.session(fromJSON: newData)
    }
}

