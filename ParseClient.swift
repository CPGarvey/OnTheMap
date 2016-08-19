//
//  ParseClient.swift
//  On The Map
//
//  Created by Chris Garvey on 1/18/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    /* Shared Session */
    var session = NSURLSession.sharedSession()
    
    
    /* Parse API task */
    func parseTask(request: NSMutableURLRequest, completionHandler: (parsedResult: AnyObject?, errorString: String?) -> Void) {
    
        request.addValue(HeaderValues.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(HeaderValues.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTaskWithRequest(request) { data, response, error in
        
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                
                completionHandler(parsedResult: nil, errorString: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                completionHandler(parsedResult: nil, errorString: "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                completionHandler(parsedResult: nil, errorString: "No data was returned by the request!")
                return
            }
            
            /* Parse the data */
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                completionHandler(parsedResult: nil, errorString: "Could Not Parse the Data as JSON.")
            }
            
            /* Return the parsed data through the completion handler */
            completionHandler(parsedResult: parsedResult, errorString: nil)
    
        }
        
        task.resume()
    }
    
    
    /* Construct a Parse URL from parameters (if parameters exist) */
    func constructParseURL(parameters: [String:AnyObject]?) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath
        components.queryItems = [NSURLQueryItem]()
        
        if parameters != nil {
        
            for (key, value) in parameters! {
                let queryItem = NSURLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
            
        }
        return components.URL!
    }
    
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
    
}