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
    
    var explore: Explore!
    var deal: Deal!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUpSegmentedController()
        self.addBackButton()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    //MARK: My Methods
    
    func setUpSegmentedController() {
        
        let collectionViewHeight = ((178.0 / 375.0) * self.view.frame.width)
        let headerViewHeight = collectionViewHeight + 83.0
        
        self.headerController = (self.storyboard!.instantiateViewController(withIdentifier: "ExploreDetailHeaderViewController") as! ExploreDetailHeaderViewController)
        headerController.explore = self.explore
        let _ = self.headerController.view
        self.headerController.collectionViewHeight.constant = collectionViewHeight
        
        self.aboutController = (self.storyboard!.instantiateViewController(withIdentifier: "ExploreDetailAboutViewController") as! ExploreDetailAboutViewController)
        self.aboutController.explore = self.explore
        self.aboutController.title = "About"
        self.aboutController.view.backgroundColor = self.containerView.backgroundColor
        
        self.dealsController = (self.storyboard!.instantiateViewController(withIdentifier: "ExploreDetailDealsViewController") as! ExploreDetailDealsViewController)
        self.dealsController.explore = self.explore
        self.dealsController.title = "Deals"
        self.dealsController.delegate = self
        self.dealsController.view.backgroundColor = self.containerView.backgroundColor
        
        self.offersController = (self.storyboard!.instantiateViewController(withIdentifier: "ExploreDetailLiveOffersViewController") as! ExploreDetailLiveOffersViewController)
        self.offersController.explore = self.explore
        self.offersController.title = "Live Offers"
        self.offersController.delegate = self
        self.offersController.view.backgroundColor = self.containerView.backgroundColor
        
        self.aboutController.automaticallyAdjustsScrollViewInsets = false
        self.dealsController.automaticallyAdjustsScrollViewInsets = false
        self.offersController.automaticallyAdjustsScrollViewInsets = false
        
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
        
    }

    //MARK: My IBActions
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getOffButtonTapped(_ sender: Any) {
        let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
        redeemStartViewController.type = .standard
        redeemStartViewController.establishmentID = self.explore.id.value
        redeemStartViewController.modalPresentationStyle = .overCurrentContext
        self.present(redeemStartViewController, animated: true, completion: nil)
    }
    
//    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!)
//    {
//        if (segue.identifier == "segueTest") {
//            var svc = segue!.destinationViewController
//
//
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ExploreDetailToOfferDetailSegue" {
            let vc = segue.destination as! OfferDetailViewController
            vc.deal = sender as? Deal
        }
    }
    
    
}

//MARK: SJSegmentedViewControllerDelegate
extension ExploreDetailViewController: SJSegmentedViewControllerDelegate {
    func didMoveToPage(_ controller: UIViewController, segment: SJSegmentTab?, index: Int) {
        
        for segment in self.segmentedController.segments {
            segment.titleColor(UIColor.white)
        }
        
        let segmentTab = self.segmentedController.segments[index]
        segmentTab.titleColor(UIColor.appBlueColor())
    }
}

//MARK: ExploreDetailDealsViewControllerDelegate
extension ExploreDetailViewController: ExploreDetailDealsViewControllerDelegate {
    func exploreDealsController(controller: ExploreDetailDealsViewController, didSelectRowAt deal: Deal) {

        self.performSegue(withIdentifier: "ExploreDetailToOfferDetailSegue", sender: deal)
    
    }
}

//MARK: ExploreDetailLiveOffersViewControllerDelegate
extension ExploreDetailViewController: ExploreDetailLiveOffersViewControllerDelegate {
    func exploreOffersController(controller: ExploreDetailLiveOffersViewController, didSelectRowAt offer: LiveOffer) {
        self.performSegue(withIdentifier: "ExploreDetailToOfferDetailSegue", sender: offer)
    }
}
