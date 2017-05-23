//
//  LoginAuthentication.swift
//  On The Map
//
//  Created by Stefan Claussen on 23/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

enum LoginResult {
    case success
    case failure(Error)
}

struct LoginAuthentication {
    
    let session = URLSession.shared
    
    func POSTSessionFor(email: String, password: String, completion: @escaping (LoginResult) -> Void) {
        // TODO: refactor request url.
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
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
        let range = Range(5..<data!.count)
        let newData = data?.subdata(in: range)
        
        guard let jsonData = newData else {
            return .failure(error!)
        }
        return ParseAPI.session(fromJSON: jsonData)
    }
}

