//
//  ExploreViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout


enum ExploreType: String {
    case bars = "bars", deals = "deals", liveOffers = "live_offers"
}

enum DisplayType: String {
    case list = "list", map = "map"
}

class ExploreViewController: UIViewController {

    @IBOutlet var tempView: UIView!
    
    @IBOutlet var segmentContainerView: UIView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var barsContainerView: UIView!
    @IBOutlet var dealsContainerView: UIView!
    @IBOutlet var liveOffersContainerView: UIView!
    
    @IBOutlet var dealsButton: UIButton!
    @IBOutlet var barsButton: UIButton!
    @IBOutlet var liveOffersButton: UIButton!
    
    var exploreType = ExploreType.bars
    
    var barsController: BarsViewController!
    var dealsController: BarsWithDealsViewController!
    var liveOffersController: BarsWithLiveOffersViewController!
    
    var defaultButtonTitleColor: UIColor!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.appNavBarGrayColor()
        self.segmentContainerView.backgroundColor = UIColor.clear
        
        self.setUpContainerViews()
        
        self.defaultButtonTitleColor = self.barsButton.titleColor(for: .normal)
        
        self.barsButton.sendActions(for: .touchUpInside)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateNavigationBarAppearance()
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    //MARK: My Methods
    
    func setUpSegmentedButtons() {
        self.dealsButton.titleLabel?.textAlignment = .center
        self.barsButton.titleLabel?.textAlignment = .center
        self.liveOffersButton.titleLabel?.textAlignment = .center
    }
    
    func resetSegmentedButton() {
        self.dealsButton.backgroundColor = self.tempView.backgroundColor
        self.barsButton.backgroundColor = self.tempView.backgroundColor
        self.liveOffersButton.backgroundColor = self.tempView.backgroundColor
        
        self.dealsButton.setTitleColor(defaultButtonTitleColor, for: .normal)
        self.barsButton.setTitleColor(defaultButtonTitleColor, for: .normal)
        self.liveOffersButton.setTitleColor(defaultButtonTitleColor, for: .normal)
    }
    
    func setUpContainerViews() {
        self.barsController = (self.storyboard!.instantiateViewController(withIdentifier: "BarsViewController") as! BarsViewController)
        self.barsController.delegate = self
        self.addViewController(controller: self.barsController, parent: self.barsContainerView)
        
        self.dealsController = (self.storyboard!.instantiateViewController(withIdentifier: "BarsWithDealsViewController") as! BarsWithDealsViewController)
        self.dealsController.delegate = self
        self.addViewController(controller: self.dealsController, parent: self.dealsContainerView)
        
        self.liveOffersController = (self.storyboard!.instantiateViewController(withIdentifier: "BarsWithLiveOffersViewController") as! BarsWithLiveOffersViewController)
        self.liveOffersController.delegate = self
        self.addViewController(controller: self.liveOffersController, parent: self.liveOffersContainerView)
    }
    
    func addViewController(controller: UIViewController, parent: UIView) {
        self.addChildViewController(controller)
        controller.willMove(toParentViewController: self)
        
        parent.addSubview(controller.view)
        
        controller.view.autoPinEdgesToSuperviewEdges()
    }
    
    func moveToBarDetail(bar: Bar) {
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
        barDetailController.selectedBar = bar
        self.present(barDetailNav, animated: true, completion: nil)
    }


    
    //MARK: My IBActions
    
    @IBAction func barsButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.exploreType = .bars
        
        dealsController.invalidateTimer()
        liveOffersController.invalidateTimer()
        
        barsController.updateSnakeBar()
        
        self.scrollView.scrollToPage(page: 0, animated: true)
    }
    
    @IBAction func dealsButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.exploreType = .deals
        
        barsController.invalidateTimer()
        liveOffersController.invalidateTimer()
        
        dealsController.updateSnakeBar()
        
        self.scrollView.scrollToPage(page: 1, animated: true)
    }
    
    @IBAction func liveOffersButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        barsController.invalidateTimer()
        dealsController.invalidateTimer()
        
        liveOffersController.updateSnakeBar()
        self.exploreType = .liveOffers
        
        self.scrollView.scrollToPage(page: 2, animated: true)
    }
}

//MARK: BarsViewControllerDelegate
extension ExploreViewController: BarsViewControllerDelegate {
    func barsController(controller: BarsViewController, didSelectBar bar: Bar) {
        self.moveToBarDetail(bar: bar)
    }
}

//MARK: BarsWithDealsViewControllerDelegate
extension ExploreViewController: BarsWithDealsViewControllerDelegate {
    func barsWithDealsController(controller: BarsWithDealsViewController, didSelect bar: Bar) {
        self.moveToBarDetail(bar: bar)
    }
}

//MARK: BarsWithLiveOffersViewControllerDelegate
extension ExploreViewController: BarsWithLiveOffersViewControllerDelegate {
    func liveOffersController(controller: BarsWithLiveOffersViewController, didSelectLiveOfferOf bar: Bar) {
        self.moveToBarDetail(bar: bar)
    }
}

