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
    
    @IBAction func loginPressed(_ sender: Any) {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            
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
