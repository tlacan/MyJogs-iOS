//
//  ServiceState.swift
//  MyJogs
//
//  Created by thomas lacan on 23/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

public enum ServiceState: Equatable {
    case idle
    case loading
    case loaded
    case error(ApiError)
    
    public func localizedDescription() -> String {
        switch self {
        case .error(let apiError):
            return apiError.localizedDescription
        default:
            return "Not an Error"
        }
    }
    
    public static func == (rhs: ServiceState, lhs: ServiceState) -> Bool {
        switch (rhs, lhs) {
        case (.idle, .idle),
             (.loading, .loading),
             (.loaded, .loaded),
             (.error, .error):
            return true
        default:
            return false
        }
    }
}
