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
    
    var loginAuthentication = LoginAuthentication()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    
    private func alertDetails(_ email: String?, _ password: String?) -> (title: String, message: String)? {
        var string = ""
        let emptyEmail = email?.isEmpty
        let emptyPassword = password?.isEmpty
        
        switch (emptyEmail, emptyPassword) {
        case (true?, true?):    string = "Email and Password"
        case (true?, false?):   string = "Email"
        case (false?, true?):   string = "Password"
        default:    return nil
        }
        
        let title =  string + " Missing"
        let message = "Enter your " + string.lowercased() + " to login"
        return (title, message)
    }
    
    private func showAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        if let information = alertDetails(emailTextField.text, passwordTextField.text) {
            showAlertWith(title: information.title, message: information.message)
        } else {
            loginAuthentication.POSTSessionFor(email: emailTextField.text!, password: passwordTextField.text!) {
                (loginResult) -> Void in
                
                switch loginResult {
                case .success:
                    self.completeLogin()
                case let .failure(error):
                    print("Error getting session: \(error)")
                }
            }
        }
    }
    
    // MARK: Helper methods
    
    private func completeLogin() {
        DispatchQueue.main.async {
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "OTMTabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        }
    }
}
