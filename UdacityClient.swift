//
//  UdacityClient.swift
//  On The Map
//
//  Created by Chris Garvey on 1/1/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    /* Shared session */
    var session = NSURLSession.sharedSession()
    
    
    /* Initialize User */
    var user = UserInformation()
    
    
    /* Udacity API task */
    func udacityTask(request: NSMutableURLRequest, userIDRequest: Bool, completionHandler: (parsedResult: AnyObject?, errorString: String?) -> Void) {
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                completionHandler(parsedResult: nil, errorString: error?.localizedDescription)
                return
            }
            
            
            /* GUARD: Did we get a successful 2XX response? If not and the request is for the userID, was the response 403? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if userIDRequest == true && (response as? NSHTTPURLResponse)?.statusCode == 403 {
                    completionHandler(parsedResult: nil, errorString: "Invalid Username or Password.")
                    return
                } else {
                    completionHandler(parsedResult: nil, errorString: "Your request returned a status code other than 2xx!")
                    return
                }
            }
        
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(parsedResult: nil, errorString: "No data was returned by the request!")
                return
            }
            
            /* Subset the data that was returned */
            let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            /* Parse the data */
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                completionHandler(parsedResult: nil, errorString: "Could Not Parse the Data as JSON.")
            }
            
            /* Return the parsed data through the completion handler */
            completionHandler(parsedResult: parsedResult, errorString: nil)
            
        }
        
        task.resume()
    }
    
    
    /* Construct a Udacity URL */
    func constructUdacityURL(withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (withPathExtension ?? "")
        
        return components.URL!
        
        
    }
    
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityClient {
    
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
    
        return Singleton.sharedInstance
    }

}
