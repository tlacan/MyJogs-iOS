//
//  OnBoardingViewController.swift
//  MyJogs
//
//  Created by thomas lacan on 14/05/2019.
//  Copyright © 2019 thomas lacan. All rights reserved.
//

import Foundation
import UIKit

class OnBoardingViewController: UIViewController {
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    let backgrounds = [nil, Asset.onboarding2.image, nil]
    let titles = [L10n.Onboarding.Step._1.title, nil, nil]
    let descriptions = [L10n.Onboarding.Step._1.description, L10n.Onboarding.Step._2.description, L10n.Onboarding.Step._3.description]
    let smallImages = [Asset.iconLogoBis.image, nil, Asset.iconShoe.image]
    let engine: Engine
    
    init(engine: Engine) {
        self.engine = engine
        super.init(nibName: "OnBoardingViewController", bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width,
                                 height: UIScreen.main.bounds.height)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.register(UINib(
            nibName: OnBoardingCollectionViewCell.nibName,
            bundle: Bundle.main
        ), forCellWithReuseIdentifier: OnBoardingCollectionViewCell.kReuseId)
    }
    
}

extension OnBoardingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnBoardingCollectionViewCell.kReuseId,
                                                            for: indexPath) as? OnBoardingCollectionViewCell else {
            fatalError()
        }
        cell.configure(title: titles[indexPath.row],
                       description: descriptions[indexPath.row],
                       background: backgrounds[indexPath.row],
                       smallImage: smallImages[indexPath.row])
        return cell
    }
    
    
}
