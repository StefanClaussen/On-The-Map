//
//  LoginViewController.swift
//  On The Map
//
//  Created by Stefan Claussen on 17/05/2017.
//  Copyright © 2017 One foot after the other. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Alert Titles
    let unableToLogin = "Unable to login"
    let signUpPageNotFound = "Sign Up Page Not Found"
    
    // MARK: - Alert Messages
    let noAccountOrInvalidCredentials = "\nMake sure your email and password are correct\n\nOR\n\nSign up for an account if you do not have one"
    let noConnection = "\nA connection could not be made. Check your internet connection."
    let unknown = "Something unexpected happened. Try again now or later."
    let noSignUpPage = "Visit www.udacity.com to sign up."
    
    
    // MARK: - Alert Actions
    let tryAgain = "Try Again"
    let okay = "Okay"
    
    var loginAuthentication = LoginAuthentication()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: Actions
    
    @IBAction func loginPressed(_ sender: Any) {
        if let information = alertDetails(emailTextField.text, passwordTextField.text) {
            showAlertWith(title: information.title, message: information.message, actionTitle: tryAgain)
        } else {
            loginAuthentication.POSTSessionFor(email: emailTextField.text!, password: passwordTextField.text!, completion: (self.processLoginResult))
        }
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        guard
            let url = URL(string: Constants.Udacity.signUpPage),
            UIApplication.shared.canOpenURL(url) else {
                showAlertWith(title: signUpPageNotFound, message: noSignUpPage, actionTitle: okay)
                return
        }
        UIApplication.shared.open(url as URL)
    }
    
    
    // MARK: Helper methods
    
    private func processLoginResult(_ loginResult: LoginResult) {
        switch loginResult {
        case .success(let key):
            Constants.LoggedInUser.uniqueKey = key
            self.completeLogin()
            // TODO: Is there a better time, to create a user?
            loginAuthentication.GETStudent {
                (result) -> Void in
                switch result {
                case .success(let student):
                    Constants.LoggedInUser.firstName = student.firstName
                    Constants.LoggedInUser.lastName = student.lastName
                case .failure(let error):
                    print("failed to create a user: \(error)")
                    return
                }
            }
        case .failure(UdacityError.accountNotFoundOrInvalidCredentials):
            self.showAlertWith(title: self.unableToLogin, message: self.noAccountOrInvalidCredentials, actionTitle: tryAgain)
        case .failure(UdacityError.noConnection):
            self.showAlertWith(title: self.unableToLogin, message: self.noConnection, actionTitle: okay)
        default:
            self.showAlertWith(title: self.unableToLogin, message: self.unknown, actionTitle: okay)
        }
    }
    
    private func completeLogin() {
        DispatchQueue.main.async {
            let tabBarController = self.storyboard?.instantiateViewController(withIdentifier: "OTMTabBarController") as! UITabBarController
            self.present(tabBarController, animated: true) {
                self.clearTextFields()
            }
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
    
    private func showAlertWith(title: String, message: String, actionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
        present(alert, animated: true, completion: {
            self.clearTextFields()
        })
    }
    
    private func clearTextFields() {
        self.emailTextField.text = nil
        self.passwordTextField.text = nil
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
