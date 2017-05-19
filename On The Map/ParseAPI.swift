//
//  ParseClient.swift
//  On The Map
//
//  Created by Stefan Claussen on 17/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import Foundation

class ParseAPI: NSObject {
    
    var session = URLSession.shared
    
    func taskForGETStudentLocation() -> Void {
        // 2/3. Build URL, Configure request
        let request = createURLRequest()
        
        // 4. Make the request
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard (error == nil) else {
                print("There was an error with your request: \(String(describing: error))")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                print("Your request returned a status code other than 2xx!")
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            // 5. Parse the data
            let parsedResult = self.convertDataToJSON(with: data, options: .allowFragments)
            print(parsedResult!)
        }
        
        // 7. Start the request
        task.resume()
    }
    
    // MARK: Helper methods
    
    private func createURLRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(url: URL(string: Constants.baseURLString)!)
        request.addValue(Constants.applicationID, forHTTPHeaderField: Constants.xParseApplicationID)
        request.addValue(Constants.apiKey, forHTTPHeaderField: Constants.xParseRestAPIKey)
        return request
    }
    
    private func convertDataToJSON(with data: Data, options: JSONSerialization.ReadingOptions ) -> [String: AnyObject]? {
        
        var parsedResult: [String: AnyObject]! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: options) as! [String: AnyObject]
        } catch {
            print("Could not parse the data as JSON: '\(data)'")
        }
        return parsedResult
    }

}
