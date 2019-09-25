//
//  JogsService.swift
//  MyJogs
//
//  Created by thomas lacan on 23/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

public protocol JogsServiceObserver {
    func onJogService(jogService: JogsService, didUpdate state: ServiceState)
}

public class JogsService: ObservableObject {
    static let kFileStore = "jogs"
    
    let networkClient: NetworkClient
    let sessionService: SessionService
    let expirableDataStore: ExpirableFileDataStore
    public var state: ServiceState = .idle {
        didSet {
            LOG("[JogsService] state changed to \(state)")
            observers.invoke { $0.onJogService(jogService: self, didUpdate: state) }
        }
    }
    var jogs: [JogModel] = [] {
        didSet {
            expirableDataStore.persist(
                codable: jogs, filename: JogsService.kFileStore, in: expirableDataStore.dataStore.rootDirectory()
            )
        }
    }
    fileprivate(set) var observers = WeakObserverOrderedSet<JogsServiceObserver>()
    
    init(networkClient: NetworkClient, sessionService: SessionService, expirableDataStore: ExpirableFileDataStore) {
        self.expirableDataStore = expirableDataStore
        self.networkClient = networkClient
        self.sessionService = sessionService
        if let cachedJogs: [JogModel] = expirableDataStore.codable(
            from: JogsService.kFileStore,
            in: expirableDataStore.dataStore.rootDirectory()
            ) {
            jogs = cachedJogs
        }
    }
    
    func initDistancesIfNeeded() {
        jogs = jogs.map { value in
            var jog = value
            jog.totalDistance = jog.computedDistance()
            return jog
        }
    }
    
    func register(observer: JogsServiceObserver) {
        observers.add(value: observer)
    }
    
    func unregister(observer: JogsServiceObserver) {
        observers.remove(value: observer)
    }
    public var didChange = PassthroughSubject<JogsService, Never>()
    
    func createRandomModel() -> JogModel {
        let beginDate = Date()
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .minute, value: Int.random(in: 1 ..< 90), to: beginDate)
        let position1 = PositionModel(lat: 48.8534, lon: 2.3488)
        let position2 = PositionModel(lat: 48.7939, lon: 2.35992)
        return JogModel(id: nil, userId: 1, position: [position1, position2],
                       beginDate: beginDate, endDate: endDate)
    }
    
    func createJog(_ jog: JogModel, onDone:@escaping (ApiError?) -> Void) {
        networkClient.call(endpoint: ApiEndpoint.createJog,
                           dict: jog.toJSONDict(),
                           headers: sessionService.authentificatedSessionHeaders()) { [weak self](asyncResult) in
                            switch asyncResult {
                            case .success:
                                self?.jogs.append(jog)
                                onDone(nil)
                                guard let strongSelf = self else { return }
                                self?.didChange.send(strongSelf)
                            case .error:
                                onDone(.networkError)
                            }
        }
    }
    
    func refreshJogs() {
        if state == .loading {
            return
        }
        state = .loading
        
        networkClient.call(endpoint: ApiEndpoint.jogs, dict: nil,
                           headers: sessionService.authentificatedSessionHeaders()) { [weak self](asyncResult) in
            switch asyncResult {
            case .success(let data, _):
                if let json = ((try? data?.mapJSON()) as Any??),
                    let jsonDict = json as? [[String: Any]] {
                    do {
                        self?.jogs = try (NetworkClient.data(from: jsonDict) ?? [])
                        self?.state = .loaded
                        guard let strongSelf = self else { return }
                        self?.didChange.send(strongSelf)
                    } catch let error {
                        LOG("[REFRESH JOGS] decoding error \(error.localizedDescription)")
                        self?.state = .error(.unexpectedApiResponse)
                    }
                } else {
                    self?.state = .error(.unexpectedApiResponse)
                }
            case .error(let error):
                self?.state = .error(error ?? .networkError)
            }
        }
    }
    
}

extension JogsService: EngineComponent {
    func onLogoutUser() {
    }
    func onEngineContextDidUpdate(from previousContext: EngineContext?, to context: EngineContext) {
    }
}
