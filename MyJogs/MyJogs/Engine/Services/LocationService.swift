//
//  LocationService.swift
//  MyJogs
//
//  Created by thomas lacan on 03/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import CoreLocation

@objc public protocol LocationServiceObserver: class {
    @objc func locationService(locationService: LocationService, didUpdateLocation location: CLLocation?)
    @objc func locationService(locationService: LocationService, didChangeAuthorization status: CLAuthorizationStatus)
}

public class LocationService: NSObject, CLLocationManagerDelegate {
    
    @objc var locationManager = CLLocationManager()
    fileprivate(set) var observers = WeakObserverOrderedSet<LocationServiceObserver>()
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    public var hasAskedForGeolocation: Bool {
        return CLLocationManager.authorizationStatus() != .notDetermined
    }
    
    @objc public var deniedGeolocationAccess: Bool {
        return CLLocationManager.authorizationStatus() == .denied
            || CLLocationManager.authorizationStatus() == .restricted
    }
    
    @objc public var hasGeolocationAccess: Bool {
        return CLLocationManager.authorizationStatus() == .authorizedWhenInUse
            || CLLocationManager.authorizationStatus() == .authorizedAlways
    }
    
    @objc public func register(observer: LocationServiceObserver) {
        assert(Thread.isMainThread, "[LocationService] register observer from background thread")
        observers.add(value: observer)
    }
    public func unregister(observer: LocationServiceObserver) {
        assert(Thread.isMainThread, "[LocationService] unregister observer from background thread")
        observers.remove(value: observer)
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            observers.invoke { $0.locationService(locationService: self, didUpdateLocation: location) }
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
