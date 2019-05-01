//
//  EngineComponent.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation

protocol EngineComponent {
    func onEngineContextDidUpdate(from previousContext: EngineContext?, to context: EngineContext)
    func onLogoutUser()
}
