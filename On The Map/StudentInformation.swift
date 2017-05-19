//
//  StudentStore.swift
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
    
    func getStudentLocation(completion: @escaping (StudentResult) -> Void) {
        let request = ParseAPI.mutableURLRequest
        let task = session.dataTask(with: request as URLRequest) {
            data, response, error in
            
            let result = self.processRequest(data: data, error: error)
            //TODO: I am not sure about the line below.
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
    }
    
    func processRequest(data: Data?, error: Error?) -> StudentResult {
        guard let jsonData = data else {
            return .failure(error!)
        }
        return ParseAPI.students(fromJSON: jsonData)
    }
    
    }
