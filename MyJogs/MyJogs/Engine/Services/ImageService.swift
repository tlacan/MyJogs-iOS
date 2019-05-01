//
//  ImageService.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import UIKit

@objc public class ImageService: NSObject {
    
    let networkClient: NetworkClient
    let sessionService: SessionService
    
    init(networkClient: NetworkClient, sessionService: SessionService) {
        self.networkClient = networkClient
        self.sessionService = sessionService
    }
    
    @discardableResult
    @objc public func getImage(url: URL, onDone: @escaping (Data?, UIImage?, String?) -> Void) -> URLSessionDataTask {
        return networkClient.call(
            url: url,
            verb: .get,
            dict: nil,
            headers: sessionService.anonymousSessionHeaders()) { (asyncResult) in
                switch asyncResult {
                case .success(let data, _):
                    if let data = data {
                        onDone(data, UIImage(data: data), nil)
                    } else {
                        onDone(nil, nil, nil)
                    }
                case .error(let error):
                    print("[ImageService] error \(String(describing: error))")
                    onDone(nil, nil, error?.localizedDescription)
                }
        }
    }
}

extension ImageService: EngineComponent {
    func onLogoutUser() { }
    func onEngineContextDidUpdate(from previousContext: EngineContext?, to context: EngineContext) { }
}
