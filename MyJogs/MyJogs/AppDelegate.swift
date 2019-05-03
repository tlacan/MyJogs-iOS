//
//  AppDelegate.swift
//  MyJogs
//
//  Created by thomas lacan on 25/04/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import UIKit
import Firebase
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var engine = AppDelegate.initEngine(appDelegate: self)

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    static func initEngine(appDelegate: SessionServiceObserver) -> Engine {
        let myJogsConfiguration = EngineConfiguration(
            api: EngineConfiguration.API(
                endpointMapperClass: MyJogsEndpointMapper.self
            ),
            session: EngineConfiguration.Session(
                anonymousBearerToken: "",
                refreshTokenClientId: "",
                refreshTokenClientSecret: ""
            )
        )
        let result = Engine(
            initialContext: EngineContext(
                applicationIsInForeground: UIApplication.shared.applicationState == .active
            ),
            configuration: myJogsConfiguration
        )
        result.sessionService.register(observer: appDelegate)
        return result
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
       
    }
}

extension AppDelegate: SessionServiceObserver {
    func onSessionService(_ service: SessionService, didUpdate sessionTokenState: SessionTokenState) {
        return
    }
    
    func onSessionService(_ service: SessionService, didRefreshTokenFail onRequest: URLRequest?) {
        return
    }
}
