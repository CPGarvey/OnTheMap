//
//  StudentInformation.swift
//  On The Map
//
//  Created by Chris Garvey on 1/4/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

import Foundation

/* Struct for each student's information */
struct StudentInformation {
    let firstName: String
    let lastName: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let mapString: String
    let updatedAt: String
    let uniqueKey: String
    
    init(dictionary: [String:AnyObject]) {
        self.firstName = dictionary["firstName"] as! String
        self.lastName = dictionary["lastName"] as! String
        self.mediaURL = dictionary["mediaURL"] as! String
        self.latitude = dictionary["latitude"] as! Double
        self.longitude = dictionary["longitude"] as! Double
        self.mapString = dictionary["mapString"] as! String
        self.updatedAt = dictionary["updatedAt"] as! String
        self.uniqueKey = dictionary["uniqueKey"] as! String
    }
    
}
