//
//  UIImage+Extensions.swift
//  MyJogs
//
//  Created by thomas lacan on 12/06/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width,
                                                                              height: CGFloat(ceil(width / size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
}
