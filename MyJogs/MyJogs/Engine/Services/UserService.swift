//
//  UserService.swift
//  MyJogs
//
//  Created by thomas lacan on 23/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class UserService: BindableObject {
    static let kFileStore = "user"
    
    let expirableDataStore: ExpirableFileDataStore
    let networkCLient: NetworkClient
    let sessionService: SessionService
    
    static let kCacheExpiration = TimeInterval(60 * 60 * 12)
    public var didChange = PassthroughSubject<UserService, Never>()
    var user: UserModel? {
        didSet {
            expirableDataStore.persist(codable: user,
            filename: UserService.kFileStore, in: expirableDataStore.dataStore.rootDirectory())
        }
    }
    
    init(networkClient: NetworkClient, sessionService: SessionService, expirableDataStore: ExpirableFileDataStore) {
        self.networkCLient = networkClient
        self.sessionService = sessionService
        self.expirableDataStore = expirableDataStore
        if let cachedUser: UserModel = expirableDataStore.codable(
            from: UserService.kFileStore,
            in: expirableDataStore.dataStore.rootDirectory()) {
            self.user = cachedUser
        }
    }
    
    func signUp(email: String, password: String, onDone:@escaping (ApiError?) -> Void) {
        let parameter = ["email": email, "password": password]
        
        networkCLient.call(endpoint: ApiEndpoint.signUp, dict: parameter) { (asyncResult) in
            switch asyncResult {
            case .success(_, let code):
                if code != 200 {
                    onDone(ApiError.apiErrorFor(code: String(code), reason: nil))
                    return
                }
                onDone(nil)
            case .error:
                onDone(.noNetwork)
            }
        }
    }
    
    func login(email: String, password: String, onDone:@escaping (ApiError?) -> Void) {
        let parameter = ["email": email, "password": password]
        networkCLient.call(endpoint: ApiEndpoint.login, dict: parameter) { [weak self](asyncResult) in
            switch asyncResult {
                case .success(let data, let code):
                    if code == 500 {
                        onDone(.wrongCredentials(nil))
                        return
                    }
                    let jsonDecoder = JSONDecoder()
                    jsonDecoder.dateDecodingStrategy = .formatted(.iso8601)
                    if let data = data,
                       let json = ((try? data.mapJSON()) as Any??),
                       let jsonDict = json as? [String: Any],
                       let user = try? jsonDecoder.decode(UserModel.self, from: data),
                       let token = jsonDict["token"] as? String {
                        self?.user = user
                        self?.sessionService.currentSession = SessionModel(accessToken: token,
                                                                           refreshToken: "",
                                                                           tokenType: .bearer,
                                                                           expiresAt: Date(),
                                                                           expiresIn: 50000)
                        onDone(nil)
                        return
                    }
                    onDone(.unexpectedApiResponse)
                case .error:
                    onDone(.noNetwork)
            }
        }
    }
}

extension UserService: EngineComponent {
    func onLogoutUser() {
    }
    func onEngineContextDidUpdate(from previousContext: EngineContext?, to context: EngineContext) {
    }
}
