//
//  OffersViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 16/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import SJSegmentedScrollView

protocol OffersViewControllerDelegate: class {
    func offersViewController(controller: OffersViewController, didSelectBanner banner: Deal)
    func offersViewController(controller: OffersViewController, didSelectExclusive exclusive: Deal)
    func offersViewController(controller: OffersViewController, didSelectLive live: LiveOffer)
}

class OffersViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var chalkboardContainerView: UIView!
    @IBOutlet var exclusiveContainerView: UIView!
    @IBOutlet var liveContainerView: UIView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var bar: Bar!
    
    var chalkboardController: ChalkBoardViewController!
    var exclusiveController: ExclusiveViewController!
    var liveController: LiveOffersViewController!
    
    weak var delegate: OffersViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.chalkboardController = (self.storyboard!.instantiateViewController(withIdentifier: "ChalkBoardViewController") as! ChalkBoardViewController)
        self.chalkboardController.bar = self.bar
        self.chalkboardController.delegate = self
        self.addChildController(controller: self.chalkboardController)
        self.chalkboardContainerView.addSubview(self.chalkboardController.view)
        self.chalkboardController.view.autoPinEdgesToSuperviewEdges()
        
        self.exclusiveController = (self.storyboard!.instantiateViewController(withIdentifier: "ExclusiveViewController") as! ExclusiveViewController)
        self.exclusiveController.bar = self.bar
        self.exclusiveController.delegate = self
        self.addChildController(controller: self.exclusiveController)
        self.exclusiveContainerView.addSubview(self.exclusiveController.view)
        self.exclusiveController.view.autoPinEdgesToSuperviewEdges()
        
        self.liveController = (self.storyboard!.instantiateViewController(withIdentifier: "LiveOffersViewController") as! LiveOffersViewController)
        self.liveController.bar = self.bar
        self.liveController.delegate = self
        self.addChildController(controller: self.liveController)
        self.liveContainerView.addSubview(self.liveController.view)
        self.liveController.view.autoPinEdgesToSuperviewEdges()
    }
    
    //MARK: My Methods
    func reset() {
        self.liveController.reset()
        self.chalkboardController.reset()
        self.exclusiveController.reset()
    }
    
    func addChildController(controller: UIViewController) {
        self.addChildViewController(controller)
        controller.willMove(toParentViewController: self)
        controller.view.backgroundColor = UIColor.clear
    }
    
    //MARK: My IBActions
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        self.scrollView.scrollToPage(page: sender.selectedSegmentIndex, animated: true)
    }
    

}

//MARK: SJSegmentedViewControllerViewSource
extension OffersViewController: SJSegmentedViewControllerViewSource {
    func viewsForSegmentControllerToObserveContentOffsetChange() -> [UIView] {
        return [self.chalkboardController.statefulTableView.innerTable,
                self.exclusiveController.statefulTableView.innerTable,
                self.liveController.statefulTableView.innerTable]
    }
}

//MARK: ChalkBoardViewControllerDelegate
extension OffersViewController: ChalkBoardViewControllerDelegate {
    func chalkBoardViewController(controller: ChalkBoardViewController, didSelect deal: Deal) {
        self.delegate.offersViewController(controller: self, didSelectBanner: deal)
    }
}

//MARK: ExclusiveViewControllerDelegate
extension OffersViewController: ExclusiveViewControllerDelegate {
    func exclusiveViewController(controller: ExclusiveViewController, didSelect deal: Deal) {
        self.delegate.offersViewController(controller: self, didSelectExclusive: deal)
    }
}

//MARK: LiveOffersViewControllerDelegate
extension OffersViewController: LiveOffersViewControllerDelegate {
    func barLiveOffersController(controller: LiveOffersViewController, didSelectRowAt offer: LiveOffer) {
        self.delegate.offersViewController(controller: self, didSelectLive: offer)
    }
}
