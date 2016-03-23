//
//  LoginViewController.swift
//  On The Map
//
//  Created by Chris Garvey on 1/1/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* Configure the UI */
        configureUI()
       
        /* Set TextField Delegate */
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        //citation: http://stackoverflow.com/questions/32281651/how-to-dismiss-keyboard-when-touching-anywhere-outside-uitextfield-in-swift
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    
    // MARK: - Text Field Delegate Method
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            loginWithUdacityCredentials()
        }
        return true
    }
    
    
    // MARK: - Actions
    
    @IBAction func loginButtonTouch(sender: AnyObject) {
        if emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            presentViewController(alert("Empty Email or Password"), animated: true, completion: nil)
        } else {
            loginWithUdacityCredentials()
        }
    }

    @IBAction func loginWithFacebookButtonTouch(sender: UIButton) {
        loginWithFacebookCredentials()
    }
    
    @IBAction func signUpButtonTouch(sender: UIButton) {
        // citation: http://stackoverflow.com/questions/26938495/make-button-hyperlink-swift
        if let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    
    // MARK: - Helper Functions
    
    func completeLogin() {
        performUIUpdatesOnMain {
            self.activityIndicator.stopAnimating()
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarNavController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func loginWithUdacityCredentials() {
        activityIndicator.startAnimating()
        
        UserInformation.user.userEmail = emailTextField.text!
        UserInformation.user.userPassword = passwordTextField.text!
        
        UdacityClient.sharedInstance().authenticate(nil) { (success, errorString) in
            if success {
                self.completeLogin()
            } else {
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                    self.presentViewController(alert(errorString!), animated: true, completion: nil)
                }
            }
        }
    }
    
    func loginWithFacebookCredentials() {
        activityIndicator.startAnimating()
        
        FacebookClient.sharedInstance().authenticateWithFacebook() { (fbToken, errorString) in
            if fbToken != nil {
                UdacityClient.sharedInstance().authenticate(fbToken!) { (success, errorString) in
                if success {
                        self.completeLogin()
                    } else {
                        performUIUpdatesOnMain {
                            self.activityIndicator.stopAnimating()
                            self.presentViewController(alert(errorString!), animated: true, completion: nil)
                        }
                    }
                }
            } else {
                if errorString != nil {
                    performUIUpdatesOnMain {
                        self.activityIndicator.stopAnimating()
                        self.presentViewController(alert(errorString!), animated: true, completion: nil)
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    /* Dismiss keyboard if user touches outside the textfields */
    func tap(gesture: UITapGestureRecognizer) {
        if emailTextField.isFirstResponder() == true {
            emailTextField.resignFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
        }
    }
    
    func configureUI() {
        /* Configure background gradient */
        view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 0.976, green: 0.557, blue: 0.137, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.973, green: 0.392, blue: 0.114, alpha: 1.0).CGColor
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = view.frame
        view.layer.insertSublayer(backgroundGradient, atIndex: 0)
    }
}
