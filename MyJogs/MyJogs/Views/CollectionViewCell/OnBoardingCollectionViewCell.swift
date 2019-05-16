//
//  OnBoardingCollectionViewCell.swift
//  MyJogs
//
//  Created by thomas lacan on 14/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import UIKit

class OnBoardingCollectionViewCell: UICollectionViewCell {
    static let kReuseId = "OnBoardingCollectionCell"
    static let nibName = "OnBoardingCollectionViewCell"
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var backgoundImage: UIImageView!
    
    func configure(title: String, description: String, background: UIImage) {
        titleLabel.text = title
        subtitleLabel.text = description
        backgoundImage.image = background
    }
    
}
