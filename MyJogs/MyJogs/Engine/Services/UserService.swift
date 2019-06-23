//
//  UserService.swift
//  MyJogs
//
//  Created by thomas lacan on 23/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

class UserService {
    let networkCLient: NetworkClient
    let sessionService: SessionService
    
    init(networkClient: NetworkClient, sessionService: SessionService) {
        self.networkCLient = networkClient
        self.sessionService = sessionService
        login()
    }
    
    func login() {
        let parameter = ["email": "poutou2@yopmail.com", "password": "Qwerty1!"]
        networkCLient.call(endpoint: ApiEndpoint.login, dict: parameter) { [weak self](asyncResult) in
            switch asyncResult {
                case .success(let data, _):
                    if let json = ((try? data?.mapJSON()) as Any??),
                       let jsonDict = json as? [String: Any],
                       let token = jsonDict["token"] as? String {
                        self?.sessionService.currentSession = SessionModel(accessToken: token,
                                                                           refreshToken: "",
                                                                           tokenType: .bearer,
                                                                           expiresAt: Date(),
                                                                           expiresIn: 5000)
                    }
                case .error:
                    break
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
