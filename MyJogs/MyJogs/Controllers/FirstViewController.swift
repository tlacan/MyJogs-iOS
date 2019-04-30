//
//  FirstViewController.swift
//  MyJogs
//
//  Created by thomas lacan on 25/04/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import UIKit
import Crashlytics

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type: .roundedRect)
        button.frame = CGRect(x: 20, y: 50, width: 100, height: 30)
        button.setTitle("Crash", for: [])
        button.addTarget(self, action: #selector(self.crashButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(button)
    }

    @IBAction func crashButtonTapped(_ sender: AnyObject) {
        Crashlytics.sharedInstance().crash()
    }
}

