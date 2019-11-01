//
//  BookmarkedViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class BookmarkedViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    var controllers: [UIViewController] = []
    
    var pageController: UIPageViewController!
    
    enum BookmarkTabType: Int {
        case offers = 0, events = 1
    }
    
    var selectedTabType = BookmarkTabType.offers
    
    var offersController: BookmarkedOfferViewController!
    var eventsController: BookmarkedEventsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.offersController = (self.storyboard!.instantiateViewController(withIdentifier: "BookmarkedOfferViewController") as! BookmarkedOfferViewController)
        self.controllers.append(self.offersController)
        
        self.eventsController = (self.storyboard!.instantiateViewController(withIdentifier: "BookmarkedEventsViewController") as! BookmarkedEventsViewController)
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
        self.selectedTabType = BookmarkTabType(rawValue: sender.selectedSegmentIndex)!
        if self.selectedTabType == BookmarkTabType.offers {
            self.moveToController(controller: self.offersController, direction: .reverse, animated: true)
        } else {
            self.moveToController(controller: self.eventsController, direction: .forward, animated: true)
        }
    }
}

//MARK: UIPageViewControllerDataSource
extension BookmarkedViewController: UIPageViewControllerDataSource {
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
extension BookmarkedViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        debugPrint("pending controllers: \(previousViewControllers)")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        debugPrint("pending controllers: \(pendingViewControllers)")
    }
}
