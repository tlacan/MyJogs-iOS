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
    @IBOutlet private weak var endButton: UIButton!
    
    let numberOfSteps = 3
    var cellBeforeDragging: Int = 0
    
    let backgrounds: [UIImage?] = [nil, nil, nil]
    let titles = [L10n.Onboarding.Step._1.title, L10n.Onboarding.Step._1.title, L10n.Onboarding.Step._1.title]
    let descriptions = [L10n.Onboarding.Step._1.description, L10n.Onboarding.Step._3.description, L10n.Onboarding.Step._2.description]
    let smallImages = [Asset.iconLogoBis.image, Asset.iconShoe.image, Asset.iconChrono.image]
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
        configureCollectionView()
        endButton.setTitle(L10n.Onboarding.End.button, for: .normal)
        endButton.layer.borderColor = UIColor.black.cgColor
        endButton.layer.borderWidth = 2
        endButton.layer.cornerRadius = 20
        endButton.isHidden = true
    }
    
    func configureCollectionView() {
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
    
    @IBAction func endButtonTouchUpInside(_ sender: Any) {
        
    }
}

extension OnBoardingViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfSteps
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentPage = Int(round(scrollView.contentOffset.x / UIScreen.main.bounds.width))
        pageControl.currentPage = currentPage
        pageControl.isHidden = currentPage == numberOfSteps - 1
        endButton.isHidden = currentPage != numberOfSteps - 1
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cellBeforeDragging = pageControl.currentPage
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        // Stop scrollView sliding:
        targetContentOffset.pointee = scrollView.contentOffset
        
        var indexPath = IndexPath(item: pageControl.currentPage, section: 0)
        if velocity.x < 0 {
            indexPath = IndexPath(item: max(0, cellBeforeDragging - 1), section: 0)
        } else if velocity.x > 0 {
            indexPath = IndexPath(item: min(cellBeforeDragging + 1, collectionView.numberOfItems(inSection: 0) - 1), section: 0)
            
        }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}
