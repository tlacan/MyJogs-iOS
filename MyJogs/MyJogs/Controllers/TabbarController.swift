//
//  TabbarController.swift
//  MyJogs
//
//  Created by thomas lacan on 12/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

class TabbarController: UITabBarController {
    
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
        super.init(nibName: nil, bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recordViewController = UINavigationController(rootViewController: RecordViewController(engine: engine))
        let tabBarImage = Asset.iconChrono.image.resizeWithWidth(width: 20)
        let recordTabBarItem = UITabBarItem(title: L10n.Tabbar.Item._1, image: tabBarImage, tag: 0)
        recordViewController.tabBarItem = recordTabBarItem
        
        let recordUIHosting = UIHostingController(rootView: RecordUIView(engine: engine).environmentObject(engine.jogsService))
        let tabBarImage2 = Asset.iconShoe.image.resizeWithWidth(width: 20)
        let recordUITabBarItem = UITabBarItem(title: L10n.Tabbar.Item._1, image: tabBarImage2, tag: 1)
        recordUIHosting.tabBarItem = recordUITabBarItem
        
        let timerUIHosting = UIHostingController(rootView: JogUIView(engine: engine, successClosure: { [weak self] in
            self?.selectedIndex = 0
        }).environmentObject(engine.locationService))
        let tabBarImage3 = Asset.iconShoe.image.resizeWithWidth(width: 20)
        let timerUITabBarItem = UITabBarItem(title: L10n.Tabbar.Item._1, image: tabBarImage3, tag: 1)
        timerUIHosting.tabBarItem = timerUITabBarItem
        
        let loginUIHosting = UIHostingController(rootView: LoginUIView(engine: engine))
        let tabBarImage4 = Asset.iconLogoBis.image.resizeWithWidth(width: 20)
        let recordUITabBarItem2 = UITabBarItem(title: L10n.Tabbar.Item._1, image: tabBarImage4, tag: 2)
        loginUIHosting.tabBarItem = recordUITabBarItem2
        
        setViewControllers([recordViewController, recordUIHosting, timerUIHosting, loginUIHosting], animated: true)
    }
}
