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

class FiveADayViewController: UIViewController {

    
    @IBOutlet weak var pagerView: FSPagerView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    var size : CGSize!
    
    var deals : [FiveADayDeal] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.deals = FiveADayDeal.getDummyList()
        
        self.pagerView.register(FiveADayCollectionViewCell.nib, forCellWithReuseIdentifier: FiveADayCollectionViewCell.reuseIdentifier)
        self.pagerView.backgroundColor = .clear
        
        size = CGSize(width: self.pagerView.frame.width - 60, height: 540.0)
        self.pagerView.itemSize = size
        
        
        self.pagerView.isInfinite = true
        self.pagerView.automaticSlidingInterval = 4.0
        
        self.pageControl.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        self.pageControl.numberOfPages = deals.count
        self.pageControl.currentPage = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.pagerView.itemSize = size
//        let transform = CGAffineTransform(scaleX: 5.0, y: 5.0)
//        self.pagerView.itemSize = self.pagerView.frame.size.applying(transform)

    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

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
        cell.setUpCell(deal: deals[index])
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
    }
    
}
