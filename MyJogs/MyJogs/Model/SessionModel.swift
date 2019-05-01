//
//  SessionModel.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

public enum TokenType: String, Codable, Equatable {
    case bearer
    
    public func headerAuthName() -> String {
        return self.rawValue.capitalized
    }
    
    public static func == (lhs: TokenType, rhs: TokenType) -> Bool {
        switch (lhs, rhs) {
        case (.bearer, .bearer): return true
        }
    }
}

public struct RefreshTokenParam: Encodable {
    let grantType: String = "refresh_token"
    var refreshToken: String
    var clientId: String
    var clientSecret: String
    
    init(clientId: String, clientSecret: String, refreshToken: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.refreshToken = refreshToken
    }
}

public struct SessionModel: Codable, Equatable {
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: TokenType
    public var expiresAt: Date
    public let expiresIn: Int
    
    public static func == (lhs: SessionModel, rhs: SessionModel) -> Bool {
        return lhs.accessToken == rhs.accessToken
            && lhs.refreshToken == rhs.refreshToken
            && lhs.tokenType == rhs.tokenType
            && lhs.expiresAt == rhs.expiresAt
    }
    
    init(accessToken: String, refreshToken: String, tokenType: TokenType, expiresAt: Date, expiresIn: Int) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expiresAt = expiresAt
        self.expiresIn = expiresIn
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let accessToken = try container.decode(String.self, forKey: .accessToken)
        let refreshToken = try container.decode(String.self, forKey: .refreshToken)
        let tokenType = try container.decode(TokenType.self, forKey: .tokenType)
        let expiresIn = try container.decode(Int.self, forKey: .expiresIn)
        let expiresAt = Date().addingTimeInterval(Double(expiresIn))
        
        self = SessionModel(
            accessToken: accessToken,
            refreshToken: refreshToken,
            tokenType: tokenType,
            expiresAt: expiresAt,
            expiresIn: expiresIn
        )
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
        case tokenType = "token_type"
    }
    
    // Converts an expiration delay to an actual date
    public static func alterExpirationData(from dict: [String: Any]) -> [String: Any] {
        var dict = dict
        if let expirationDelay = dict["expiresIn"] as? Int {
            dict["expiresAt"] = Date().addingTimeInterval(Double(expirationDelay)).iso8601
        }
        return dict
    }
}
