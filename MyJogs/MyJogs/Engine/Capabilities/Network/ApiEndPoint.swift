//
//  ApiEndPoint.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

protocol EndpointMapper {
    static func path(for endpoint: ApiEndpoint) -> String
    static func method(for endpoint: ApiEndpoint) -> HTTPVerb
}

enum ApiEndpoint {
    
    // user
    case login
    case createJog
    case jogs
}
