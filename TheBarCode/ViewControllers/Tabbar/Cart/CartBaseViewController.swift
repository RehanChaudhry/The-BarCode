//
//  CartBaseViewController.swift
//  TheBarCode
//
//  Created by Macbook on 16/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

class CartBaseViewController: UIViewController {
    
    @IBOutlet var contentView: UIView!

    @IBOutlet var myCartButton: UIButton!
    @IBOutlet var myCartLineView: UIView!
    
    @IBOutlet var myOrdersButton: UIButton!
    @IBOutlet var myOrdersLineView: UIView!
    
    @IBOutlet var segmentContainerView: UIView!

    @IBOutlet weak var myCartCountLabel: UILabel!
    
    var myCartViewController: MyCartViewController!
    var myOrdersViewController: MyOrdersViewController!
    
    
    var controllers: [UIViewController] = []
    
    var pageController: UIPageViewController!
    
    var defaultButtonTitleColor: UIColor!
    
    var selectedTabType: MyTabType = .cart
    
    enum MyTabType: Int {
        case cart = 0, orders = 1
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.myCartCountLabel.layer.cornerRadius = 8
        self.myCartCountLabel.clipsToBounds = true


        self.defaultButtonTitleColor = self.myCartButton.titleColor(for: .normal)
              
        self.myCartViewController = (self.storyboard!.instantiateViewController(withIdentifier: "MyCartViewController") as! MyCartViewController)
        self.controllers.append(self.myCartViewController)
              
        self.myOrdersViewController = (self.storyboard!.instantiateViewController(withIdentifier: "MyOrdersViewController") as! MyOrdersViewController)
        self.controllers.append(self.myOrdersViewController)
          
        self.setupPageController()
        self.moveToController(controller: self.myCartViewController, direction: .forward, animated: false)
        self.resetSegmentedButton()
       // self.myCartButton.backgroundColor = UIColor.black
        self.myCartButton.setTitleColor(UIColor.appBlueColor(), for: .normal)
        self.myCartLineView.isHidden = false
        self.myCartLineView.backgroundColor = UIColor.appBlueColor()
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
//        self.myCartButton.backgroundColor = self.tempView.backgroundColor
//        self.myOrdersButton.backgroundColor = self.tempView.backgroundColor
        
//
        
        self.myCartLineView.isHidden = true
        self.myOrdersLineView.isHidden = true

        self.myCartButton.setTitleColor(defaultButtonTitleColor, for: .normal)
        self.myOrdersButton.setTitleColor(defaultButtonTitleColor, for: .normal)
    }
    
    func moveToController(controller: UIViewController, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
        self.pageController.setViewControllers([controller], direction: direction, animated: animated) { (completed: Bool) in
            
        }
    }
    
    //MARK: My IBActions
    @IBAction func myCartButtonTapped(sender: UIButton) {
        
        let currentController = self.pageController.viewControllers!.first!
        let indexOfCurrentController = self.controllers.firstIndex(of: currentController)!
        
        guard indexOfCurrentController != MyTabType.cart.rawValue else {
            debugPrint("Already showing the controller")
            return
        }
        
        let direction = MyTabType.cart.rawValue > indexOfCurrentController ? UIPageViewControllerNavigationDirection.forward : .reverse
        
        self.resetSegmentedButton()
        
        //sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
      
        self.myOrdersLineView.isHidden = true
        self.myCartLineView.isHidden = false
        self.myCartLineView.backgroundColor = UIColor.appBlueColor()
        
        self.selectedTabType = MyTabType.cart
        
        self.moveToController(controller: self.myCartViewController, direction: direction, animated: true)
        
    }
    
    @IBAction func myOrdersButtonTapped(sender: UIButton) {
        
        let currentController = self.pageController.viewControllers!.first!
        let indexOfCurrentController = self.controllers.firstIndex(of: currentController)!
        
        guard indexOfCurrentController != MyTabType.orders.rawValue else {
            debugPrint("Already showing the controller")
            return
        }
        
        let direction = MyTabType.orders.rawValue > indexOfCurrentController ? UIPageViewControllerNavigationDirection.forward : .reverse
        
        self.resetSegmentedButton()
        
       // sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.myCartLineView.isHidden = true
        self.myOrdersLineView.isHidden = false
        self.myOrdersLineView.backgroundColor = UIColor.appBlueColor()
        
        self.selectedTabType = MyTabType.orders
        
        self.moveToController(controller: self.myOrdersViewController, direction: direction, animated: true)
    }
    
}


//MARK: UIPageViewControllerDataSource
extension CartBaseViewController: UIPageViewControllerDataSource {
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
extension CartBaseViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        debugPrint("pending controllers: \(previousViewControllers)")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        debugPrint("pending controllers: \(pendingViewControllers)")
    }
}
