//
//  ExploreDetailHeaderViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class ExploreDetailHeaderViewController: UIViewController {

    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var favouriteButton: UIButton!
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    var images: [String] = ["cover_detail", "cover_detail", "cover_detail"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        self.pageControl.numberOfPages = self.images.count
        
        self.favouriteButton.tintColor = UIColor.appLightGrayColor()
        self.collectionView.register(cellType: ExploreDetailHeaderCollectionViewCell.self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension ExploreDetailHeaderViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: ExploreDetailHeaderCollectionViewCell.self)
        cell.setUpCell(imageName: self.images[indexPath.item])
        return cell
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout
extension ExploreDetailHeaderViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
}
