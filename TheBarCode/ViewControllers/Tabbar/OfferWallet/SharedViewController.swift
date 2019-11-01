//
//  SharedViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class SharedViewController: UIViewController {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var controllers: [UIViewController] = []
    
    var pageController: UIPageViewController!
    
    enum SharedTabType: Int {
        case offers = 0, events = 1
    }
    
    var selectedTabType = SharedTabType.offers
    
    var offersController: SharedOffersViewController!
    var eventsController: SharedEventsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.offersController = (self.storyboard!.instantiateViewController(withIdentifier: "SharedOffersViewController") as! SharedOffersViewController)
        self.controllers.append(self.offersController)
        
        self.eventsController = (self.storyboard!.instantiateViewController(withIdentifier: "SharedEventsViewController") as! SharedEventsViewController)
        self.controllers.append(self.eventsController)
        
        self.setupPageController()
        self.moveToController(controller: self.offersController, direction: .forward, animated: false)
    }
    
    //MARK: My Methods
    func setupPageController() {
        self.pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        self.pageController.dataSource = self
        self.pageController.delegate = self
        
        self.addChildViewController(self.pageController)
        self.pageController.willMove(toParentViewController: self)
        self.contentView.addSubview(self.pageController.view)
        
        self.pageController.view.autoPinEdgesToSuperviewEdges()
        
        for aView in self.pageController.view.subviews {
            if let scrollView = aView as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        }
    }
    
    func moveToController(controller: UIViewController, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
        self.pageController.setViewControllers([controller], direction: direction, animated: animated) { (completed: Bool) in
            
        }
    }
    
    //MARK: My IBActions
    @IBAction func segmentedControlValueChanged(sender: UISegmentedControl) {
        self.selectedTabType = SharedTabType(rawValue: sender.selectedSegmentIndex)!
        if self.selectedTabType == SharedTabType.offers {
            self.moveToController(controller: self.offersController, direction: .reverse, animated: true)
        } else {
            self.moveToController(controller: self.eventsController, direction: .forward, animated: true)
        }
    }
}

//MARK: UIPageViewControllerDataSource
extension SharedViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = self.controllers.firstIndex(of: viewController), (index - 1) >= 0 {
            return self.controllers[index - 1]
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.controllers.firstIndex(of: viewController), ((index + 1) < self.controllers.count) {
            return self.controllers[index + 1]
        } else {
            return nil
        }
    }
}

//MARK: UIPageViewControllerDelegate
extension SharedViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        debugPrint("pending controllers: \(previousViewControllers)")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        debugPrint("pending controllers: \(pendingViewControllers)")
    }
}

