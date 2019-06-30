//
//  ApiError.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

public enum ApiError: Error, Equatable {
    static let kUnexpectedReason = L10n.Apierror.unexpectedError
    static let kUnhandledErrorCode = L10n.Apierror.unhandledErrorCode
    
    static let kCodeUserExists = "409"
    
    case noNetwork
    case networkError
    case unexpectedApiResponse
    case unlogged
    case accessDenied
    case unknownEmail
    case invalidGrant
    case userNotExists
    case userExists(String?)
    case wrongCredentials(String?)
    case wrongCode(String?)
    
    case other(error: Error?)
    
    public static func apiErrorFor(code: String?, reason: String?) -> ApiError {
        guard let code = code else {
            let localizedReason = reason ?? kUnexpectedReason
            let error = NSError(domain: "API.Error", code: 0, userInfo: [NSLocalizedDescriptionKey: localizedReason])
            return .other(error: error)
        }
        
        switch code {
        case ApiError.kCodeUserExists: return userExists(L10n.Apierror.userExists)
        default:
            let description: String = reason ?? L10n.Apierror.common
            let error = NSError(
                domain: "API.Error",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: description]
            )
            return .other(error: error)
        }
    }
    
    public var localizedDescription: String {
        switch self {
        case .invalidGrant: return L10n.Apierror.accessDenied
        case .noNetwork: return L10n.Apierror.nonetworkError
        case .networkError: return L10n.Apierror.networkError
        case .unexpectedApiResponse: return L10n.Apierror.unexpectedResponse
        case .unlogged: return L10n.Apierror.notConnected
        case .accessDenied: return L10n.Apierror.accessDenied
        case .unknownEmail: return L10n.Apierror.unknwonEmail
        case .userNotExists: return L10n.Apierror.unknwonUser
        case .userExists(let reason): return reason ?? L10n.Apierror.userExists
        case .wrongCredentials(let reason): return reason ?? L10n.Apierror.wrongCredentials
        case .wrongCode(let reason): return reason ?? ApiError.kUnexpectedReason
        case .other(let error): return error?.localizedDescription ?? ApiError.kUnexpectedReason
        }
    }
    
    public static func from(error: Error?) -> ApiError {
        if let error = error as? ApiError {
            return error
        } else {
            if let nserror = error as NSError? {
                if nserror.code == NSURLErrorNotConnectedToInternet {
                    return .noNetwork
                }
            }
            return .other(error: error)
        }
    }
    
    public static func == (lhs: ApiError, rhs: ApiError) -> Bool {
        switch (lhs, rhs) {
        case (.noNetwork, .noNetwork),
             (.invalidGrant, .invalidGrant),
             (.networkError, .networkError),
             (.unexpectedApiResponse, .unexpectedApiResponse),
             (.unlogged, .unlogged),
             (.accessDenied, .accessDenied),
             (.unknownEmail, .unknownEmail),
             (.userNotExists, .userNotExists),
             (.userExists, .userExists),
             (.wrongCredentials, .wrongCredentials),
             (.wrongCode, .wrongCode),
             (.other, .other):
            return true
        default:
            return false
        }
    }
}
