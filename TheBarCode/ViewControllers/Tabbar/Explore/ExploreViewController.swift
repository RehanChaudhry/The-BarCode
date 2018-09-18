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
    case deals = "deals", bars = "bars", liveOffers = "liveOffers"
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
    var dealsController: DealsViewController!
    var liveOffersController: LiveOffersViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.appNavBarGrayColor()
        self.segmentContainerView.backgroundColor = UIColor.clear
        
        self.setUpContainerViews()
        
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
    }
    
    func setUpContainerViews() {
        self.barsController = self.storyboard!.instantiateViewController(withIdentifier: "BarsViewController") as! BarsViewController
        self.addViewController(controller: self.barsController, parent: self.barsContainerView)
        
        self.dealsController = self.storyboard!.instantiateViewController(withIdentifier: "DealsViewController") as! DealsViewController
        self.addViewController(controller: self.dealsController, parent: self.dealsContainerView)
        
        self.liveOffersController = self.storyboard!.instantiateViewController(withIdentifier: "LiveOffersViewController") as! LiveOffersViewController
        self.addViewController(controller: self.liveOffersController, parent: self.liveOffersContainerView)
    }
    
    func addViewController(controller: UIViewController, parent: UIView) {
        self.addChildViewController(controller)
        controller.willMove(toParentViewController: self)
        
        parent.addSubview(controller.view)
        
        controller.view.autoPinEdgesToSuperviewEdges()
    }
    
    //MARK: My IBActions
    
    @IBAction func barsButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        
        self.exploreType = .bars
        
        self.scrollView.scrollToPage(page: 0, animated: true)
    }
    
    @IBAction func dealsButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        
        self.exploreType = .deals
        
        self.scrollView.scrollToPage(page: 1, animated: true)
    }
    
    @IBAction func liveOffersButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        
        self.exploreType = .liveOffers
        
        self.scrollView.scrollToPage(page: 2, animated: true)
    }
    
    

}
