//
//  ExploreTableViewCell.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import FSPagerView

protocol ExploreBaseTableViewCellDelegate: class {
    func exploreBaseTableViewCell(cell: ExploreBaseTableViewCell, didSelectItem itemIndexPath: IndexPath)
}

class ExploreBaseTableViewCell: UITableViewCell {

    @IBOutlet var coverImageView: AsyncImageView!
    
    @IBOutlet var locationIconImageView: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var distanceButton: UIButton!
    
    @IBOutlet var statusButton: UIButton!
    
    @IBOutlet var pagerView: FSPagerView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var topPadding: NSLayoutConstraint!
    
    @IBOutlet var unlimitedRedemptionView: ShadowView!
    
    var bar: Explore?
    
    weak var exploreBaseDelegate: ExploreBaseTableViewCellDelegate?
    
    var imageSliderTimer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = UIColor.clear
        self.backgroundColor = UIColor.clear
        self.pagerView.backgroundColor = UIColor.clear
        self.pagerView.backgroundView = nil
        
        self.coverImageView.layer.cornerRadius = 8.0
        self.pagerView.layer.cornerRadius = 8.0
        self.pagerView.isInfinite = true
        
        self.locationIconImageView.tintColor = UIColor.appBlueColor()
        self.locationIconImageView.image = #imageLiteral(resourceName: "icon_map").withRenderingMode(.alwaysTemplate)
        self.distanceButton.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.titleLabel.textColor = UIColor.white
        
        self.selectionStyle = .none

        let nib = UINib(nibName: "ExploreImageCell", bundle: Bundle.main)
        self.pagerView.register(nib, forCellWithReuseIdentifier: "ExploreImageCell")
        
        self.pagerView.transformer = FSPagerViewTransformer(type: .crossFading)
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpCell(explore: Bar) {
        
        self.bar = explore
        self.pagerView.reloadData()
        
        self.pageControl.numberOfPages = self.bar?.images.count ?? 0
        self.pageControl.isHidden = self.pageControl.numberOfPages <= 1
        
        titleLabel.text = explore.title.value
        self.distanceButton.setTitle(Utility.shared.getformattedDistance(distance: explore.distance.value), for: .normal)
        
        locationIconImageView.isHidden = false
        
        self.setupStatus(explore: explore)
        
        self.unlimitedRedemptionView.isHidden = !explore.currentlyUnlimitedRedemptionAllowed
    }
    
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
    
    func setupStatus(explore: Explore) {
        UIView.performWithoutAnimation {
            if explore.currentlyBarIsOpened {
                self.statusButton.backgroundColor = UIColor.appStatusButtonOpenColor().withAlphaComponent(0.6)
                self.statusButton.setTitleColor(UIColor.appBlueColor(), for: .normal)
                self.statusButton.setTitle("Open", for: .normal)
            } else {
                self.statusButton.setTitleColor(UIColor.appRedColor(), for: .normal)
                self.statusButton.backgroundColor = UIColor.appStatusButtonColor().withAlphaComponent(0.6)
                self.statusButton.setTitle("Closed", for: .normal)
            }
            
            self.statusButton.layoutIfNeeded()
        }
    }
}

//MARK: FSPagerViewDataSource, FSPagerViewDelegate
extension ExploreBaseTableViewCell: FSPagerViewDataSource, FSPagerViewDelegate {
    
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
        self.exploreBaseDelegate?.exploreBaseTableViewCell(cell: self, didSelectItem: indexPath)
    }
}
