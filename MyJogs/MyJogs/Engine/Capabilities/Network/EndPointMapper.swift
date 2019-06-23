//
//  EndPointMapper.swift
//  MyJogs
//
//  Created by thomas lacan on 03/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

struct MyJogsEndpointMapper: EndpointMapper {
    // swiftlint:disable cyclomatic_complexity function_body_length
    static func path(for endpoint: ApiEndpoint) -> String {
        switch endpoint {
            case .login:
                return "/login"
            case .createJog, .jogs:
                return "/jogs"
        }
    }
    
    static func method(for endpoint: ApiEndpoint) -> HTTPVerb {
        switch endpoint {
        case .login, .createJog:
            return .post
        case .jogs:
            return .get
        }
    }
}
