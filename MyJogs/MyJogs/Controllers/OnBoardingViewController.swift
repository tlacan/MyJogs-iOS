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
    
    let backgrounds = [Asset.onboarding1.image, Asset.onboarding2.image]
    let titles = [L10n.Onboarding.Step._1.title, L10n.Onboarding.Step._2.title]
    let descriptions = [L10n.Onboarding.Step._1.description, L10n.Onboarding.Step._2.description]
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
        layout.sectionInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
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
                       background: backgrounds[indexPath.row])
        return cell
    }
    
    
}
