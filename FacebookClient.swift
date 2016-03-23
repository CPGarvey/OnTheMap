//
//  FacebookClient.swift
//  On The Map
//
//  Created by Chris Garvey on 1/31/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation

import FBSDKCoreKit
import FBSDKLoginKit
import Bolts

class FacebookClient: NSObject {
    
    // MARK: - Main Authentication Function
    
    func authenticateWithFacebook(completionHandler: (fbToken: String?, errorString: String?) -> Void) {
        
        if FBSDKAccessToken.currentAccessToken() != nil {
            FBSDKLoginManager().logOut()
        }
        
        FBSDKLoginManager().logInWithReadPermissions(["public_profile"], handler: { (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            if error != nil {
                FBSDKLoginManager().logOut()
                completionHandler(fbToken: nil, errorString: "There Was an Error Logging in to Facebook")
            } else if result.isCancelled {
                FBSDKLoginManager().logOut()
                completionHandler(fbToken: nil, errorString: nil)
            } else {
                let fbToken = result.token.tokenString
                completionHandler(fbToken: fbToken, errorString: nil)
            }
        })
        
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> FacebookClient {
        
        struct Singleton {
            static var sharedInstance = FacebookClient()
        }
        
        return Singleton.sharedInstance
    }
    
}