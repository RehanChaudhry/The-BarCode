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
    
    @IBOutlet var segmentContainer: UIView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var bar: Bar!
    
    var chalkboardController: ChalkBoardViewController!
    var exclusiveController: ExclusiveViewController!
    var liveController: LiveOffersViewController!
    var eventsController: EventsViewController!
    
    weak var delegate: OffersViewControllerDelegate!
    weak var delegateWhatsOnViewController: WhatsOnViewControllerDelegate!
    
    var preSelectedTabIndex: Int = 0
    var eventsContainer: UIView!
    
    var viewDidLayout: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.segmentContainer.backgroundColor = UIColor.appNavBarGrayColor()
        
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
        
        self.eventsController = (self.storyboard!.instantiateViewController(withIdentifier: "EventsViewController") as! EventsViewController)
        self.eventsController.bar = self.bar
        self.eventsController.delegate = self
        self.addChildController(controller: self.eventsController)
        self.liveContainerView.addSubview(self.eventsController.view)
        self.eventsController.view.autoPinEdgesToSuperviewEdges()

        
//        self.liveController = (self.storyboard!.instantiateViewController(withIdentifier: "LiveOffersViewController") as! LiveOffersViewController)
//        self.liveController.bar = self.bar
//        self.liveController.delegate = self
//        self.addChildController(controller: self.liveController)
//        self.liveContainerView.addSubview(self.liveController.view)
//        self.liveController.view.autoPinEdgesToSuperviewEdges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !self.viewDidLayout {
            self.viewDidLayout = true
            
            self.segmentedControl.selectedSegmentIndex = self.preSelectedTabIndex
            self.segmentedControl.sendActions(for: .valueChanged)
        }
        
    }
    
    //MARK: My Methods
    func reset() {
        self.liveController.reset()
        self.chalkboardController.reset()
        self.exclusiveController.reset()
        self.eventsController.reset()
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
                self.eventsController.statefulTableView.innerTable]
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

//MARK: EventsViewControllerDelegate
extension OffersViewController: EventsViewControllerDelegate {
    func eventsViewController(controller: EventsViewController, didSelect event: Event) {
        self.delegateWhatsOnViewController.whatsOnViewController(controller: WhatsOnViewController(), didSelect: event)
    }
}

