//
//  LocationService.swift
//  MyJogs
//
//  Created by thomas lacan on 03/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI
import Combine

public protocol LocationServiceObserver {
    func locationService(locationService: LocationService, didUpdateLocation location: CLLocation?)
    func locationService(locationService: LocationService, didChangeAuthorization status: CLAuthorizationStatus)
    func loactionService(locationService: LocationService, didChangeSpeed speed: CLLocationSpeed)
}

public class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    var locationManager = CLLocationManager()
    fileprivate(set) var observers = WeakObserverOrderedSet<LocationServiceObserver>()
    
    var lastLocation: CLLocation?
    var currentJog: JogModel?
    public var didChange = PassthroughSubject<LocationService, Never>()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    public var hasAskedForGeolocation: Bool {
        return CLLocationManager.authorizationStatus() != .notDetermined
    }
    
    public var deniedGeolocationAccess: Bool {
        return CLLocationManager.authorizationStatus() == .denied
            || CLLocationManager.authorizationStatus() == .restricted
    }
    
    public var hasGeolocationAccess: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
            || CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    public func register(observer: LocationServiceObserver) {
        assert(Thread.isMainThread, "[LocationService] register observer from background thread")
        observers.add(value: observer)
    }
    public func unregister(observer: LocationServiceObserver) {
        assert(Thread.isMainThread, "[LocationService] unregister observer from background thread")
        observers.remove(value: observer)
    }
    
    func startTracking(currentJog: JogModel) {
        if !hasAskedForGeolocation {
            locationManager.requestAlwaysAuthorization()
        }
        self.currentJog = currentJog
        locationManager.startUpdatingLocation()
    }
    
    func stopTracking(duration: Date?) {
        if let duration = duration {
            let endDate = currentJog?.beginDate.addingTimeInterval(duration.timeIntervalSince1970)
            currentJog?.endDate = endDate
        }
        locationManager.stopUpdatingLocation()
        lastLocation = nil
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastLocation = location
            currentJog?.position.append(PositionModel(lat: location.coordinate.latitude, lon: location.coordinate.longitude))
            didChange.send(self)
            observers.invoke { $0.locationService(locationService: self, didUpdateLocation: location) }
            observers.invoke { $0.loactionService(locationService: self, didChangeSpeed: location.speed)}
        }
    }
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        observers.invoke { $0.locationService(locationService: self, didChangeAuthorization: status) }
    }
}

extension LocationService: EngineComponent {
    func onLogoutUser() { }
    func onEngineContextDidUpdate(from previousContext: EngineContext?, to context: EngineContext) { }
}
