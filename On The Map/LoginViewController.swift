//
//  LoginViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 17/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Login
    
    @IBAction func loginPressed(_ sender: Any) {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            
        } else {
            
            authenticateWithUdacity()
        }
    }
    
    // MARK: Parse 
    
    private func authenticateWithUdacity() {
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func displayError(_ error: String) {
                print(error)
                
            }
            
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range)
            
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: newData!, options: .allowFragments) as! [String: AnyObject]
                self.completeLogin()
            } catch {
                displayError("Could not parse the data as JSON: '\(String(describing: data))'")
                return
            }
        }
        task.resume()
    }
    
    private func completeLogin() {
        DispatchQueue.main.async {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "OTMTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
}
