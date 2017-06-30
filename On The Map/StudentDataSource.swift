//
//  StudentDataSource.swift
//  On The Map
//
//  Created by Stefan Claussen on 29/06/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

class StudentDataSource {
    var studentData = [StudentInformation]()
    static let shared = StudentDataSource()
    private init() {}
    
    func fetchStudentLocations(completion: @escaping (Result<Bool>) -> Void) {
        
        NetworkingManager.GETStudentLocation {
            // Unowned because it is a singleton, and singleton can never be nil
            [unowned self] (studentsResult) in
            
            switch studentsResult {
            case let .success(students):
                self.studentData = students
                completion(.success(true))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

