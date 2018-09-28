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
    
    var aboutController: ExploreAboutViewController!
    var dealsController: ExploreDealsViewController!
    var offersController: ExploreLiveOffersViewController!
    
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
        self.headerController = self.storyboard!.instantiateViewController(withIdentifier: "ExploreDetailHeaderViewController") as! ExploreDetailHeaderViewController
        
        self.aboutController = self.storyboard!.instantiateViewController(withIdentifier: "ExploreAboutViewController") as! ExploreAboutViewController
        self.aboutController.title = "About"
        
        self.dealsController = self.storyboard!.instantiateViewController(withIdentifier: "ExploreDealsViewController") as! ExploreDealsViewController
        self.dealsController.title = "Deals"
        
        self.offersController = self.storyboard!.instantiateViewController(withIdentifier: "ExploreLiveOffersViewController") as! ExploreLiveOffersViewController
        self.offersController.title = "Live Offers"
        
        self.segmentedController = SJSegmentedViewController(headerViewController: self.headerController, segmentControllers: [self.aboutController, self.dealsController, self.offersController])
        self.segmentedController.headerViewHeight = ((178.0 / 375.0) * self.view.frame.width)

        self.addChildViewController(self.segmentedController)
        self.segmentedController.willMove(toParentViewController: self)
        self.containerView.addSubview(self.segmentedController.view)
        
        self.segmentedController.view.autoPinEdgesToSuperviewEdges()
    }

}
