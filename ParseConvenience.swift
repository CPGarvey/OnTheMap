//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Chris Garvey on 2/6/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import UIKit
import Foundation

extension ParseClient {
    
    //MARK: - Convenience Methods
    
    func getStudentLocations(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let parameters = [ParameterKeys.Limit: 100, ParameterKeys.Order: "-updatedAt"]
        
        let request = NSMutableURLRequest(URL: constructParseURL(parameters))
        
        parseTask(request) { parsedResult, errorString in
            
            guard (errorString == nil) else {
                completionHandler(success: false, errorString: errorString)
                return
            }
            
            guard let results = parsedResult!["results"] as? [[String:AnyObject]] else {
                completionHandler(success: false, errorString: "Unable to Obtain Student Locations from Server.")
                return
            }
            
            /* Clear the students array */
            StudentData.students = []
            
            for student in results {
                let information = StudentInformation(dictionary: student)
                StudentData.students.append(information)
            }
            
            completionHandler(success: true, errorString: nil)
        }
        
    }
    
    func postStudentLocationAndLink(completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let jsonBody: [String:AnyObject] = [JSONBodyKeys.UniqueKey: UserInformation.user.userID!, JSONBodyKeys.FirstName: UserInformation.user.firstName!, JSONBodyKeys.LastName: UserInformation.user.lastName!, JSONBodyKeys.MapString: UserInformation.user.mapString!, JSONBodyKeys.MediaURL: UserInformation.user.mediaURL!, JSONBodyKeys.Latitude: UserInformation.user.userPointAnnotation!.coordinate.latitude, JSONBodyKeys.Longitude: UserInformation.user.userPointAnnotation!.coordinate.longitude]
        
        let request = NSMutableURLRequest(URL: constructParseURL(nil))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: .PrettyPrinted)
        }
        
        parseTask(request) { parsedResult, errorString in
            
            if (errorString == nil) {
                completionHandler(success: true, errorString: nil)
            } else {
                completionHandler(success: false, errorString: "Unable to Post User Location and Data.")
                return
            }
        }
    }
    
}