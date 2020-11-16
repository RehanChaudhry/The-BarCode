//
//  OfferWalletViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 02/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout

class OfferWalletViewController: UIViewController {

    @IBOutlet var contentView: UIView!
    
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var sharedButton: UIButton!
    @IBOutlet var bookmarkButton: UIButton!
    
    @IBOutlet var tempView: UIView!
    
    @IBOutlet var segmentContainerView: UIView!
    
    var favouritesController: FavouritesViewController!
    var sharedController: SharedViewController!
    var bookmarkedController: BookmarkedViewController!
    
    var controllers: [UIViewController] = []
    
    var pageController: UIPageViewController!
    
    var defaultButtonTitleColor: UIColor!
    
    var selectedTabType: OfferWalletTabType = .favourite
    
    enum OfferWalletTabType: Int {
        case favourite = 0, shared = 1, bookmarked = 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.defaultButtonTitleColor = self.favouriteButton.titleColor(for: .normal)
        
        self.favouritesController = (self.storyboard!.instantiateViewController(withIdentifier: "FavouritesViewController") as! FavouritesViewController)
        self.controllers.append(self.favouritesController)
        
        self.sharedController = (self.storyboard!.instantiateViewController(withIdentifier: "SharedViewController") as! SharedViewController)
        self.controllers.append(self.sharedController)
        
        self.bookmarkedController = (self.storyboard!.instantiateViewController(withIdentifier: "BookmarkedViewController") as! BookmarkedViewController)
        self.controllers.append(self.bookmarkedController)
        
        self.setupPageController()
        self.moveToController(controller: self.favouritesController, direction: .forward, animated: false)
        self.resetSegmentedButton()
        self.favouriteButton.backgroundColor = UIColor.black
        self.favouriteButton.setTitleColor(UIColor.appBlueColor(), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
    
    func resetSegmentedButton() {
        self.favouriteButton.backgroundColor = self.tempView.backgroundColor
        self.sharedButton.backgroundColor = self.tempView.backgroundColor
        self.bookmarkButton.backgroundColor = self.tempView.backgroundColor
        
        self.favouriteButton.setTitleColor(defaultButtonTitleColor, for: .normal)
        self.sharedButton.setTitleColor(defaultButtonTitleColor, for: .normal)
        self.bookmarkButton.setTitleColor(defaultButtonTitleColor, for: .normal)
    }
    
    func moveToController(controller: UIViewController, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
        self.pageController.setViewControllers([controller], direction: direction, animated: animated) { (completed: Bool) in
            
        }
    }
    
    //MARK: My IBActions
    
    @IBAction func closeButtonTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func favouriteButtonTapped(sender: UIButton) {
        
        let currentController = self.pageController.viewControllers!.first!
        let indexOfCurrentController = self.controllers.firstIndex(of: currentController)!
        
        guard indexOfCurrentController != OfferWalletTabType.favourite.rawValue else {
            debugPrint("Already showing the controller")
            return
        }
        
        let direction = OfferWalletTabType.favourite.rawValue > indexOfCurrentController ? UIPageViewControllerNavigationDirection.forward : .reverse
        
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.selectedTabType = OfferWalletTabType.favourite
        
        self.moveToController(controller: self.favouritesController, direction: direction, animated: true)
        
    }
    
    @IBAction func sharedOfferButtonTapped(sender: UIButton) {
        
        let currentController = self.pageController.viewControllers!.first!
        let indexOfCurrentController = self.controllers.firstIndex(of: currentController)!
        
        guard indexOfCurrentController != OfferWalletTabType.shared.rawValue else {
            debugPrint("Already showing the controller")
            return
        }
        
        let direction = OfferWalletTabType.shared.rawValue > indexOfCurrentController ? UIPageViewControllerNavigationDirection.forward : .reverse
        
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.selectedTabType = OfferWalletTabType.shared
        
        self.moveToController(controller: self.sharedController, direction: direction, animated: true)
    }
    
    @IBAction func bookmarkedButtonTapped(sender: UIButton) {
        
        let currentController = self.pageController.viewControllers!.first!
        let indexOfCurrentController = self.controllers.firstIndex(of: currentController)!
        
        guard indexOfCurrentController != OfferWalletTabType.bookmarked.rawValue else {
            debugPrint("Already showing the controller")
            return
        }
        
        let direction = OfferWalletTabType.bookmarked.rawValue > indexOfCurrentController ? UIPageViewControllerNavigationDirection.forward : .reverse
        
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.selectedTabType = OfferWalletTabType.bookmarked
        
        self.moveToController(controller: self.bookmarkedController, direction: direction, animated: true)
    }
}

//MARK: UIPageViewControllerDataSource
extension OfferWalletViewController: UIPageViewControllerDataSource {
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
extension OfferWalletViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        debugPrint("pending controllers: \(previousViewControllers)")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        debugPrint("pending controllers: \(pendingViewControllers)")
    }
}
