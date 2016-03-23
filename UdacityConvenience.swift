//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Chris Garvey on 2/6/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import Foundation


extension UdacityClient {
    
    // MARK: - Authentication Process 
    
    /* Authenticate with Udacity credentials */
    func authenticate(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        self.getUserID(nil) { (success, errorString) in
            
            if success {
                
                self.getUserName() { (success, errorString) in
                    
                    completionHandler(success: success, errorString: errorString)
                }
                
            } else {
                
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    /* Authenticate with Facebook token */
    func authenticate(fbToken: String?, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        self.getUserID(fbToken) { (success, errorString) in
            
            if success {
                
                self.getUserName() { (success, errorString) in
                    
                    completionHandler(success: success, errorString: errorString)
                }
                
            } else {
                
                completionHandler(success: success, errorString: errorString)
            }
        }
    }
    
    
    // MARK: - Convenience Methods
    
    func getUserID(fbToken: String?, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        var jsonBody: [String:[String:String]]
        
        if fbToken != nil {
            jsonBody = [JSONBodyKeys.FacebookMobile: [JSONBodyKeys.AccessToken: fbToken!]]
        } else {
            jsonBody = [JSONBodyKeys.Udacity: [JSONBodyKeys.Username: UserInformation.user.userEmail!, JSONBodyKeys.Password: UserInformation.user.userPassword!]]
        }
        
        let request = NSMutableURLRequest(URL: constructUdacityURL(Methods.Session))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        self.udacityTask(request, userIDRequest: true) { parsedResult, errorString in
            
            /* GUARD: Was there an error? */
            guard (errorString == nil) else {
                completionHandler(success: false, errorString: errorString)
                return
            }
            
            /* GUARD: Can user account dictionary be obtained? */
            guard let userAccount = parsedResult!["account"] as? [String:AnyObject] else {
                completionHandler(success: false, errorString: "Unable to Locate User Account Information.")
                return
            }
            
            /* Obtain userID from the user account dictionary */
            if let userID = userAccount["key"] as? String {
                UserInformation.user.userID = userID
                completionHandler(success: true, errorString: nil)
            } else {
                completionHandler(success: false, errorString: "Unable to Obtain Student User ID.")
            }
        }
    }
    
    func getUserName(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: constructUdacityURL(Methods.Users + UserInformation.user.userID!))
        
        self.udacityTask(request, userIDRequest: false) { parsedResult, errorString in
            
            /* GUARD: Was there an error? */
            guard (errorString == nil) else {
                completionHandler(success: false, errorString: errorString)
                return
            }
            
            /* Obtain first name and last name of user from user dictionary */
            if let userDictionary = parsedResult!["user"] as? [String:AnyObject] {
                UserInformation.user.firstName = userDictionary["first_name"] as? String
                UserInformation.user.lastName = userDictionary["last_name"] as? String
                completionHandler(success: true, errorString: nil)
            }
        }
    }
    
    /* Log out of Udacity */
    func logoutUdacity(completionHandler: (errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: constructUdacityURL(Methods.Session))
        
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        self.udacityTask(request, userIDRequest: false) { parsedResult, errorString in
            
            /* GUARD: Was there an error? */
            guard (errorString == nil) else {
                completionHandler(errorString: "Unable to Fully Complete Logout Request.")
                return
            }
            
            completionHandler(errorString: nil)
        }
    }
    
}