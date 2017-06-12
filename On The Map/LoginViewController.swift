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
    
    let unableToLogin = "Unable to login"
    let noAccountOrInvalidCredentials = "\nMake sure your email and password are correct\n\nOR\n\nSign up for an account if you do not have one"
    let noConnection = "\nA connection could not be made. Check your internet connection."
    let unknown = "Something unexpected happened. Try logging in again."
    let tryAgain = "Try Again"
    
    var loginAuthentication = LoginAuthentication()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    
    @IBAction func loginPressed(_ sender: Any) {
        if let information = alertDetails(emailTextField.text, passwordTextField.text) {
            showAlertWith(title: information.title, message: information.message)
        } else {
            loginAuthentication.POSTSessionFor(email: emailTextField.text!, password: passwordTextField.text!, completion: (self.processLoginResult))
        }
    }
    
    // MARK: Helper methods
    
    private func processLoginResult(_ loginResult: LoginResult) {
        switch loginResult {
        case .success(let key):
            Constants.LoggedInUser.uniqueKey = key
            self.completeLogin()
        case .failure(UdacityError.accountNotFoundOrInvalidCredentials):
            self.showAlertWith(title: self.unableToLogin, message: self.noAccountOrInvalidCredentials)
        case .failure(UdacityError.noConnection):
            self.showAlertWith(title: self.unableToLogin, message: self.noConnection)
        default:
            self.showAlertWith(title: self.unableToLogin, message: self.unknown)
        }
    }
    
    private func completeLogin() {
        DispatchQueue.main.async {
            let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "OTMTabBarController") as! UITabBarController
            self.present(tabBarController, animated: true, completion: nil)
        }
    }
    
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
        alert.addAction(UIAlertAction(title: tryAgain, style: .default, handler: nil))
        present(alert, animated: true, completion: {
            self.emailTextField.text = nil
            self.passwordTextField.text = nil
        })
    }
    
}
