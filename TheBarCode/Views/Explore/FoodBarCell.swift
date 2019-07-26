//
//  FoodBarCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 26/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FSPagerView

protocol FoodBarCellDelegate: class {
    func foodBarCell(cell: FoodBarCell, didSelectPagerItemAt indexPath: IndexPath)
}

class FoodBarCell: UITableViewCell, NibReusable {
    
    @IBOutlet var pagerView: FSPagerView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var titleLabel: UILabel!
    
    var bar: Explore?
    
    weak var delegate: FoodBarCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        
        self.pagerView.backgroundColor = UIColor.clear
        self.pagerView.backgroundView = nil
        self.pagerView.layer.cornerRadius = 8.0
        self.pagerView.isInfinite = true
        
        self.titleLabel.textColor = UIColor.white
        
        let nib = UINib(nibName: "ExploreImageCell", bundle: Bundle.main)
        self.pagerView.register(nib, forCellWithReuseIdentifier: "ExploreImageCell")
        
        self.pagerView.transformer = FSPagerViewTransformer(type: .crossFading)
        
    }
    
    //MARK: My Methods
    func scrollToCurrentImage() {
        
        let imagesCount = self.bar?.images.count ?? 0
        let currentIndex = self.bar?.currentImageIndex ?? 0
        
        if currentIndex < imagesCount {
            self.pageControl.currentPage = currentIndex
            self.pagerView.layoutIfNeeded()
            self.pagerView.scrollToItem(at: currentIndex, animated: false)
        } else {
            self.pageControl.currentPage = 0
            self.pagerView.layoutIfNeeded()
            self.pagerView.scrollToItem(at: 0, animated: false)
        }
    }
    
    func setUpCell(explore: Bar) {
        
        self.bar = explore
        self.pagerView.reloadData()
        
        self.pageControl.numberOfPages = self.bar?.images.count ?? 0
        
        self.titleLabel.text = explore.title.value
    }
}

//MARK: FSPagerViewDataSource, FSPagerViewDelegate
extension FoodBarCell: FSPagerViewDataSource, FSPagerViewDelegate {
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        self.pageControl.currentPage = targetIndex
        self.bar?.currentImageIndex = targetIndex
    }
    
    func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
        self.bar?.currentImageIndex = pagerView.currentIndex
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return self.bar?.images.count ?? 0
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = self.pagerView.dequeueReusableCell(withReuseIdentifier: "ExploreImageCell", at: index) as! ExploreImageCell
        cell.setUpCell(imageName: self.bar!.images[index].url.value)
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let indexPath = IndexPath(item: index, section: 0)
        self.delegate.foodBarCell(cell: self, didSelectPagerItemAt: indexPath)
    }
}
