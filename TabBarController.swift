//
//  TabBarController.swift
//  On The Map
//
//  Created by Chris Garvey on 1/3/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class TabBarController: UITabBarController {

    @IBAction func logout(sender: UIBarButtonItem) {
        
        FBSDKLoginManager().logOut()
        
        UdacityClient.sharedInstance().logoutUdacity() { (errorString) in
            if errorString != nil {
                print(errorString!)
            }
            
            performUIUpdatesOnMain {
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
}
