//
//  Engine.swift
//  MyJogs
//
//  Created by thomas lacan on 03/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import KeychainSwift

struct EngineConfiguration {
    struct API {
        let endpointMapperClass: EndpointMapper.Type
    }
    struct Session {
        let anonymousBearerToken: String
        let refreshTokenClientId: String
        let refreshTokenClientSecret: String
    }
    
    let api: API
    let session: Session
}

@objc public class Engine: NSObject {
    
    static let kUDWasLaunchedOnce = "kUDWasLaunchedOnce"
    static var wasLaunchedOnce = UserDefaults.standard.bool(forKey: Engine.kUDWasLaunchedOnce) {
        didSet {
            UserDefaults.standard.set(wasLaunchedOnce, forKey: Engine.kUDWasLaunchedOnce)
        }
    }
    
    // MARK: - Context
    fileprivate (set) var context: EngineContext
    
    // MARK: - Capabilities
    fileprivate let dataStore: FileDataStore
    fileprivate let expirableFileDataStore: ExpirableFileDataStore
    fileprivate let httpClient: NetworkClient
    
    // MARK: - Services
    let sessionService: SessionService
    let imageService: ImageService
    let locationService: LocationService
    let jogsService: JogsService
    let userService: UserService
    let appUpdated: Bool
    
    // MARK: - Server image accesor
    let remoteImageAccessor: RemoteImageDataStore
    
    fileprivate var allComponents: [EngineComponent?] {
        return [
            //Capabilities
            dataStore,
            httpClient,
            expirableFileDataStore,
            
            //Service
            sessionService,
            imageService,
            remoteImageAccessor,
            locationService,
            jogsService,
            userService
        ]
    }
    
    // swiftlint:disable function_body_length
    init(initialContext: EngineContext,
         configuration: EngineConfiguration,
         mockedDatastore: FileDataStore? = nil,
         mockedExpirableFileDataStore: ExpirableFileDataStore? = nil,
         mockedRemoteImageAccessor: RemoteImageDataStore? = nil,
         mockedNetworkClient: NetworkClient? = nil,
         mockedSessionService: SessionService? = nil,
         mockedImageService: ImageService? = nil,
         mockedLocationService: LocationService? = nil,
         mockedUserService: UserService? = nil,
         mockedJogsService: JogsService? = nil
        ) {
        
        if !Engine.wasLaunchedOnce {
            Engine.clearKeychain()
            Engine.wasLaunchedOnce = true
        }
        
        // Assign dependencies to constants first to avoid `capturing self before all instance variable initialized` while injecting
        // Capabilities
        let dataStore = mockedDatastore ?? FileDataStore()
        let httpClient = mockedNetworkClient ?? NetworkClient(endpointMapperClass: configuration.api.endpointMapperClass
        )
        let expirableFileDataStore = mockedExpirableFileDataStore ?? ExpirableFileDataStore(
            dataStore: dataStore
        )
        
        // Services
        let locationService = mockedLocationService ?? LocationService()
        let sessionService = mockedSessionService ?? SessionService(
            networkClient: httpClient, dataStore: dataStore,
            tokenCliendId: configuration.session.refreshTokenClientId,
            tokenClientSecret: configuration.session.refreshTokenClientSecret,
            anonymousBearerToken: configuration.session.anonymousBearerToken
        )
        let imageService = mockedImageService ?? ImageService(
            networkClient: httpClient, sessionService: sessionService
        )
        remoteImageAccessor = mockedRemoteImageAccessor ?? RemoteImageDataStore(
            imageService: imageService, dataStore: dataStore
        )
        self.locationService = locationService
        self.sessionService = sessionService
        self.dataStore = dataStore
        self.httpClient = httpClient
        self.expirableFileDataStore = expirableFileDataStore
        self.imageService = imageService
        self.userService = mockedUserService ?? UserService(networkClient: httpClient, sessionService: sessionService)
        self.jogsService = mockedJogsService ?? JogsService(networkClient: httpClient, sessionService: sessionService,
                                                            expirableDataStore: expirableFileDataStore)
        
        //Context
        context = initialContext
        appUpdated = Engine.checkAppUpdated()
        super.init()
        propagateContext(oldValue: nil)
    }
    
    private static func checkAppUpdated() -> Bool {
        let standardUserDefaults = UserDefaults.standard
        let shortVersionKey = "CFBundleShortVersionString"
        guard let currentVersion = Bundle.main.infoDictionary?[shortVersionKey] as? String else { return  false}
        guard let previousVersion = standardUserDefaults.object(forKey: shortVersionKey) as? String else {
            standardUserDefaults.set(currentVersion, forKey: shortVersionKey)
            return false
        }
        standardUserDefaults.set(currentVersion, forKey: shortVersionKey)
        return previousVersion != currentVersion
    }
    
    static func clearKeychain() {
        let keychain = KeychainSwift()
        keychain.synchronizable = true
        keychain.clear()
    }
    
    @objc func logoutUser() {
        allComponents.forEach { $0?.onLogoutUser() }
    }
    
    // MARK: - Internal flow
    fileprivate func propagateContext(oldValue: EngineContext?) {
        allComponents.forEach { $0?.onEngineContextDidUpdate(from: oldValue, to: context) }
    }
    
    // MARK: Application State
    public func onApplicationDidEnterBackground() {
        let previousContext = context
        context.applicationIsInForeground = false
        propagateContext(oldValue: previousContext)
    }
    
    public func onApplicationDidBecomeActive() {
        let previousContext = context
        context.applicationIsInForeground = true
        propagateContext(oldValue: previousContext)
    }
}
