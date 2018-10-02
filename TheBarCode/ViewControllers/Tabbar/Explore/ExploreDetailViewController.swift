//
//  ExploreDetailViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import SJSegmentedScrollView
import PureLayout

class ExploreDetailViewController: UIViewController {
    
    @IBOutlet var containerView: UIView!
    
    var headerController: ExploreDetailHeaderViewController!
    
    var aboutController: ExploreDetailAboutViewController!
    var dealsController: ExploreDetailDealsViewController!
    var offersController: ExploreDetailLiveOffersViewController!
    
    var segmentedController: SJSegmentedViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUpSegmentedController()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My Methods
    
    func setUpSegmentedController() {
        
        let collectionViewHeight = ((178.0 / 375.0) * self.view.frame.width)
        let headerViewHeight = collectionViewHeight + 83.0
        
        self.headerController = (self.storyboard!.instantiateViewController(withIdentifier: "ExploreDetailHeaderViewController") as! ExploreDetailHeaderViewController)
        let _ = self.headerController.view
        self.headerController.collectionViewHeight.constant = collectionViewHeight
        
        self.aboutController = (self.storyboard!.instantiateViewController(withIdentifier: "ExploreDetailAboutViewController") as! ExploreDetailAboutViewController)
        self.aboutController.title = "About"
        self.aboutController.view.backgroundColor = self.containerView.backgroundColor
        
        self.dealsController = (self.storyboard!.instantiateViewController(withIdentifier: "ExploreDetailDealsViewController") as! ExploreDetailDealsViewController)
        self.dealsController.title = "Deals"
        self.dealsController.view.backgroundColor = self.containerView.backgroundColor
        
        self.offersController = (self.storyboard!.instantiateViewController(withIdentifier: "ExploreDetailLiveOffersViewController") as! ExploreDetailLiveOffersViewController)
        self.offersController.title = "Live Offers"
        self.offersController.view.backgroundColor = self.containerView.backgroundColor
        
        self.segmentedController = SJSegmentedViewController(headerViewController: self.headerController, segmentControllers: [self.aboutController, self.dealsController, self.offersController])
        self.segmentedController.delegate = self
        self.segmentedController.headerViewHeight = headerViewHeight
        self.segmentedController.segmentViewHeight = 44.0
        self.segmentedController.selectedSegmentViewHeight = 1.0
        self.segmentedController.selectedSegmentViewColor = UIColor.appBlueColor()
        self.segmentedController.segmentTitleColor = UIColor.white
        self.segmentedController.segmentBackgroundColor = self.headerController.view.backgroundColor!
        self.segmentedController.segmentTitleFont = UIFont.appRegularFontOf(size: 16.0)

        self.addChildViewController(self.segmentedController)
        self.segmentedController.willMove(toParentViewController: self)
        self.containerView.addSubview(self.segmentedController.view)
        
        self.segmentedController.view.autoPinEdgesToSuperviewEdges()
        
//        self.segmentedController.
    }

}

extension ExploreDetailViewController: SJSegmentedViewControllerDelegate {
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {
        
        for segment in self.segmentedController.segments {
            segment.titleColor(UIColor.white)
        }
        
        let segmentTab = self.segmentedController.segments[index]
        segmentTab.titleColor(UIColor.appBlueColor())
    }
}
