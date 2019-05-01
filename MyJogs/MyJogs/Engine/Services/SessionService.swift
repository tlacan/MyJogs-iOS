//
//  SessionService.swift
//  MyJogs
//
//  Created by thomas lacan on 01/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import KeychainSwift

public enum SessionTokenState: Equatable {
    case unknown
    case valid
    case refreshing
    case unrefreshable(ApiError?)
    
    public static func == (lhs: SessionTokenState, rhs: SessionTokenState) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown),
             (.valid, .valid),
             (.refreshing, .refreshing),
             (.unrefreshable, .unrefreshable):
            return true
        default: return false
        }
    }
}

public protocol SessionServiceObserver {
    func onSessionService(_ service: SessionService, didUpdate sessionTokenState: SessionTokenState)
    func onSessionService(_ service: SessionService, didRefreshTokenFail onRequest: URLRequest?)
}

public class SessionService: NSObject {
    
    let networkClient: NetworkClient
    let dataStore: FileDataStore
    let anonymousBearerToken: String
    let tokenCliendId: String
    let tokenClientSecret: String
    
    static let kLoadingTag = "session"
    static let kAuthorizationHeader = "Authorization"
    
    fileprivate(set) var observers = WeakObserverOrderedSet<SessionServiceObserver>()
    
    private var timer: Timer?
    public var sessionTokenState: SessionTokenState = .unknown {
        didSet {
            observers.invoke { $0.onSessionService(self, didUpdate: sessionTokenState) }
        }
    }
    
    init(networkClient: NetworkClient, dataStore: FileDataStore, tokenCliendId: String, tokenClientSecret: String, anonymousBearerToken: String) {
        self.networkClient = networkClient
        self.dataStore = dataStore
        self.tokenCliendId = tokenCliendId
        self.tokenClientSecret = tokenClientSecret
        self.anonymousBearerToken = anonymousBearerToken
        
        super.init()
        networkClient.register(observer: self)
    }
    
    // MARK: - Observer
    public func register(observer: SessionServiceObserver) {
        assert(Thread.isMainThread, "[SessionService] register observer from background thread")
        observers.add(value: observer)
        observer.onSessionService(self, didUpdate: sessionTokenState)
    }
    public func unregister(observer: SessionServiceObserver) {
        assert(Thread.isMainThread, "[SessionService] unregister observer from background thread")
        observers.remove(value: observer)
    }
    
    // MARK: - Refresh
    public func refreshTokenWhenNeeded() {
        guard let currentSession = currentSession else { return }
        let expirationDelay = currentSession.expiresAt.timeIntervalSinceNow
        if expirationDelay < 0 {
            refreshToken()
        } else {
            LOG("[SessionService] Token will expire in \(expirationDelay) seconds", .info)
            sessionTokenState = .valid
            timer?.invalidate()
            timer = Timer.scheduledTimer(
                timeInterval: expirationDelay,
                target: self,
                selector: #selector(SessionService.refreshToken),
                userInfo: nil,
                repeats: false
            )
        }
    }
    
    @objc private func refreshToken() {
        refreshToken(onDone: nil)
    }
    
    // swiftlint:disable:next function_body_length
    internal func refreshToken(onDone: ((ApiError?) -> Void)? = nil) {
        LOG("[SessionService] Token expired, trying to refresh...", .info)
        /*
        guard let currentSession = currentSession,
            sessionTokenState != .refreshing,
            let payload = RefreshTokenParam(clientId: tokenCliendId, clientSecret: tokenClientSecret, refreshToken: currentSession.refreshToken).toJSONDict()?
                .convertKeys(to: .snakeCase)
            else {
                return
        }
        
        sessionTokenState = .refreshing
        
        let endpoint = ""//ApiEndpoint.refreshAuthToken
        networkClient.call(
            endpoint: endpoint,
            dict: payload,
            headers: nil) { [weak self] (asyncResult) in
                guard let strongSelf = self else { return }
                switch asyncResult {
                case .success(let data, let code):
                    // refresh token invalid log out user
                    if code == 400 {
                        guard let strongSelf = self else { return }
                        strongSelf.observers.invoke { $0.onSessionService(strongSelf, didRefreshTokenFail: nil) }
                        let error = ApiError.accessDenied
                        strongSelf.sessionTokenState = .unrefreshable(error)
                        onDone?(error)
                        self?.firebaseService?.networkError(fromEntryPoint: FranprixEndpointMapper.path(for: endpoint), description: error.localizedDescription, errorCode: code)
                        return
                    }
                    do {
                        if  let sessionDict = try data?.mapJSON() as? [String: Any],
                            let session = try SessionService.session(from: sessionDict["token"] as? [String: Any] ?? [:]) {
                            strongSelf.currentSession = session
                            strongSelf.sessionTokenState = .valid
                            onDone?(nil)
                        } else {
                            let error = ApiError.unexpectedApiResponse
                            strongSelf.sessionTokenState = .unrefreshable(error)
                            onDone?(error)
                            self?.firebaseService?.networkError(fromEntryPoint: FranprixEndpointMapper.path(for: endpoint), description: error.localizedDescription, errorCode: code)
                        }
                    } catch let error {
                        do {
                            if  let sessionDict = try data?.mapJSON() as? [String: Any] {
                                if let errorCode = sessionDict[NetworkClient.kResponseError] as? String {
                                    let error = ApiError.apiErrorFor(code: errorCode, reason: nil)
                                    strongSelf.sessionTokenState = .unrefreshable(error)
                                    self?.firebaseService?.networkError(fromEntryPoint: FranprixEndpointMapper.path(for: endpoint), description: error.localizedDescription, errorCode: code)
                                    return
                                }
                            }
                            strongSelf.sessionTokenState = .unrefreshable(ApiError.from(error: error))
                            self?.firebaseService?.networkError(fromEntryPoint: FranprixEndpointMapper.path(for: endpoint), description: error.localizedDescription, errorCode: code)
                        } catch let error {
                            strongSelf.sessionTokenState = .unrefreshable(ApiError.from(error: error))
                            self?.firebaseService?.networkError(fromEntryPoint: FranprixEndpointMapper.path(for: endpoint), description: error.localizedDescription, errorCode: code)
                        }
                    }
                case .error(let error):
                    LOG("[UserService] refreshToken error \(String(describing: error))", .error)
                    let apiError = ApiError.from(error: error)
                    strongSelf.sessionTokenState = .unrefreshable(apiError)
                    onDone?(apiError)
                }
        }
         */
    }
    
    public static func session(from dict: [String: Any]) throws -> SessionModel? {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601) // .iso8601 not available prior to iOS 11
        let data = try JSONSerialization.data(
            withJSONObject: dict,
            options: []
        )
        return try decoder.decode(SessionModel.self, from: data)
    }
    
    // MARK: - Auth helper
    func authentificatedSessionHeaders() -> [String: String] {
        // Version full swift later
        guard let currentSession = currentSession else { return [:] }
        return [
            SessionService.kAuthorizationHeader: "\(currentSession.tokenType.headerAuthName()) \(currentSession.accessToken)"
        ]
    }
    
    // for objc network model
    @objc func headerForOldNetworkClient() -> String? {
        guard let currentSession = currentSession else { return nil }
        return "Bearer \(currentSession.accessToken)"
    }
    
    public func anonymousSessionHeaders() -> [String: String] {
        return [:]
    }
}

extension SessionService {
    // Migrating from datastore-stored session token to keychain
    private static let kCurrentSessionFileName = "currentSession"
    private static let kKeychainSessionTokenKey = "sessionToken"
    
    public var currentSession: SessionModel? {
        get {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.dateDecodingStrategy = .formatted(.iso8601)
            
            let keychain = KeychainSwift()
            keychain.synchronizable = true
            do {
                if  let data = keychain.getData(SessionService.kKeychainSessionTokenKey) {
                    let sessionModel = try jsonDecoder.decode(SessionModel.self, from: data)
                    LOG("[SessionService] Returning currentSession from keyChain")
                    return sessionModel
                } else if let legacySessionToken: SessionModel = dataStore.codable(
                    from: SessionService.kCurrentSessionFileName, in: dataStore.rootDirectory()
                    ) {
                    LOG("[SessionService] Reading legacy sessiontoken, migrating...")
                    dataStore.deleteFileIfExists(in: dataStore.rootDirectory(), filename: SessionService.kCurrentSessionFileName)
                    self.currentSession = legacySessionToken
                    LOG("[SessionService] Returning sessiontToken")
                    return legacySessionToken
                } else {
                    return nil
                }
            } catch let error {
                LOG("[SessionService] Unable to read token from keychain \(error)")
                return nil
            }
        }
        set(currentSession) {
            let keychain = KeychainSwift()
            keychain.synchronizable = true
            if let currentSession = currentSession {
                let jsonEncoder = JSONEncoder()
                jsonEncoder.dateEncodingStrategy = .formatted(.iso8601)
                do {
                    let data = try jsonEncoder.encode(currentSession)
                    keychain.set(data, forKey: SessionService.kKeychainSessionTokenKey)
                    LOG("[SessionService] Stored sessionToken to keychain")
                } catch let error {
                    LOG("[SessionService] Error persisting sessionToken \(error)")
                }
            } else {
                LOG("[SessionService] Deleting sessionToken from keyChain")
                keychain.delete(SessionService.kKeychainSessionTokenKey)
            }
            refreshTokenWhenNeeded()
        }
    }
}

extension SessionService: NetworkClientObserver {
    // Intercepts 401 if any and refresh token if not already refreshing
    func onNetworkClient(networkClient: NetworkClient, didReceiveUnauthorizedAccessFor request: URLRequest, onDoneRetryingRequest: @escaping (AsyncCallResult<Data>) -> Void) {
        
    }
}

extension SessionService: EngineComponent {
    func onLogoutUser() {
        currentSession = nil
        sessionTokenState = .unknown
        timer?.invalidate()
        timer = nil
    }
    func onEngineContextDidUpdate(from previousContext: EngineContext?, to context: EngineContext) {
        if context.applicationIsInForeground {
            refreshTokenWhenNeeded()
        }
    }
}
