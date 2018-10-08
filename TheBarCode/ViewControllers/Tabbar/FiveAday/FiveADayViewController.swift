//
//  FiveADayViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FSPagerView

protocol FiveADayViewControllerDelegate {
    func showPopup()
}


class FiveADayViewController: UIViewController {

    
    @IBOutlet var pagerView: FSPagerView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    var deals : [FiveADayDeal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.deals = FiveADayDeal.getDummyList()
        
        self.pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        self.pageControl.numberOfPages = deals.count
        self.pagerView.isInfinite = true
        self.pageControl.currentPage = 0
        self.pagerView.backgroundColor = .clear
        self.pagerView.automaticSlidingInterval = 4.0
        self.pagerView.register(FiveADayCollectionViewCell.nib, forCellWithReuseIdentifier: FiveADayCollectionViewCell.reuseIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cellWidth = (self.view.frame.width / 100.0 * 85.0)
        let cellHeight = self.pagerView.frame.size.height
        
        self.pagerView.itemSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
}



//MARK: FSPagerViewDataSource, FSPagerViewDelegate

extension FiveADayViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        return false
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return deals.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let identifier = FiveADayCollectionViewCell.reuseIdentifier
        let cell = self.pagerView.dequeueReusableCell(withReuseIdentifier: identifier, at: index) as! FiveADayCollectionViewCell
        cell.delegate = self
        cell.setUpCell(deal: deals[index])
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
    }
}

extension FiveADayViewController: FiveADayViewControllerDelegate{
    func showPopup() {
        let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
        redeemStartViewController.modalPresentationStyle = .overCurrentContext
        self.present(redeemStartViewController, animated: true, completion: nil)
    }
}
