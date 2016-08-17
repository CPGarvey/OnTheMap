//
//  ParseConstants.swift
//  On The Map
//
//  Created by Chris Garvey on 2/6/16.
//  Copyright © 2016 Chris Garvey. All rights reserved.
//

extension ParseClient {
    
    // MARK: - Constants
    
    struct Constants {
        
        /* URLs */
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
    }
    
    
    // MARK: - Methods
    
    struct Methods {
        static let Session = "/session"
        static let Users = "/users/"
    }
    
    
    // MARK: - Parameter Keys
    
    struct ParameterKeys {
        static let Limit = "limit"
        static let Order = "order"
    }
    
    
    // MARK: - JSON Body Keys
    
    struct JSONBodyKeys {
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    
    // MARK: - Header Values
    
    struct HeaderValues {
        static let ApplicationID = "[Enter Application ID Here]"
        static let ApiKey = "[Enter API Key Here]"
    }
    
}
