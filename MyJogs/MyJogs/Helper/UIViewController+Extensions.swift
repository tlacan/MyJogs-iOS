//
//  UIViewController+Extensions.swift
//  MyJogs
//
//  Created by thomas lacan on 19/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
     func hasTopNotch() -> Bool {
        if #available(iOS 11, *) {
            if UIApplication.shared.delegate != nil && UIApplication.shared.delegate?.window != nil {
                return (UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0.0) > 0
            }
            return false
        } else {
        let screenHeight = Int(UIScreen.main.nativeBounds.size.height)
            if screenHeight == 2436 || screenHeight == 1792 || screenHeight == 2688 {
                return true
            }
        }
        return false
     }
    
}
