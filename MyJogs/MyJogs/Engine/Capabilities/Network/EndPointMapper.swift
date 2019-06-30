//
//  EndPointMapper.swift
//  MyJogs
//
//  Created by thomas lacan on 03/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

struct MyJogsEndpointMapper: EndpointMapper {
    static func path(for endpoint: ApiEndpoint) -> String {
        switch endpoint {
            case .login:
                return "/login"
            case .createJog, .jogs:
                return "/jogs"
            case .signUp:
                return "/register"
        }
    }
    
    static func method(for endpoint: ApiEndpoint) -> HTTPVerb {
        switch endpoint {
        case .login, .createJog, .signUp:
            return .post
        case .jogs:
            return .get
        }
    }
}
