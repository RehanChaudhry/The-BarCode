//
//  OfferWalletViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 02/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit

class OfferWalletViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var bookmarkedContainer: UIView!
    @IBOutlet var favouriteContainer: UIView!
    @IBOutlet var sharedContainer: UIView!
    
    @IBOutlet var favouriteButton: UIButton!
    @IBOutlet var sharedButton: UIButton!
    @IBOutlet var bookmarkButton: UIButton!
    
    @IBOutlet var tempView: UIView!
    
    @IBOutlet var segmentContainerView: UIView!
    
    var favouritesController: FavouritesViewController!
    var sharedOffersController: SharedOffersViewController!
    var bookmarkedController: BookmarkedOfferViewController!
    
    var defaultButtonTitleColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.defaultButtonTitleColor = self.favouriteButton.titleColor(for: .normal)
        
        self.setupController()
        self.favouriteButton.sendActions(for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: My Methods
    func setupController() {
        self.favouritesController = (self.storyboard!.instantiateViewController(withIdentifier: "FavouritesViewController") as! FavouritesViewController)
        self.sharedOffersController = (self.storyboard!.instantiateViewController(withIdentifier: "SharedOffersViewController") as! SharedOffersViewController)
        self.bookmarkedController = (self.storyboard!.instantiateViewController(withIdentifier: "BookmarkedOfferViewController") as! BookmarkedOfferViewController)
        
        self.addChildViewController(self.favouritesController)
        self.favouritesController.willMove(toParentViewController: self)
        self.favouriteContainer.addSubview(self.favouritesController.view)
        self.favouritesController.view.autoPinEdgesToSuperviewEdges()
        self.favouritesController.view.backgroundColor = UIColor.clear
        self.favouritesController.shouldShowFirstItemPadding = false
        
        self.addChildViewController(self.sharedOffersController)
        self.sharedOffersController.willMove(toParentViewController: self)
        self.sharedContainer.addSubview(self.sharedOffersController.view)
        self.sharedOffersController.view.autoPinEdgesToSuperviewEdges()
        self.sharedOffersController.view.backgroundColor = UIColor.clear
        self.sharedOffersController.shouldShowFirstItemPadding = false
        
        self.addChildViewController(self.bookmarkedController)
        self.bookmarkedController.willMove(toParentViewController: self)
        self.bookmarkedContainer.addSubview(self.bookmarkedController.view)
        self.bookmarkedController.view.autoPinEdgesToSuperviewEdges()
        self.bookmarkedController.view.backgroundColor = UIColor.clear
        self.bookmarkedController.shouldShowFirstItemPadding = false
    }
    
    func resetSegmentedButton() {
        self.favouriteButton.backgroundColor = self.tempView.backgroundColor
        self.sharedButton.backgroundColor = self.tempView.backgroundColor
        self.bookmarkButton.backgroundColor = self.tempView.backgroundColor
        
        self.favouriteButton.setTitleColor(defaultButtonTitleColor, for: .normal)
        self.sharedButton.setTitleColor(defaultButtonTitleColor, for: .normal)
        self.bookmarkButton.setTitleColor(defaultButtonTitleColor, for: .normal)
    }
    
    //MARK: My IBActions
    @IBAction func favouriteButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.scrollView.scrollToPage(page: 0, animated: true)
    }
    
    @IBAction func sharedOfferButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.scrollView.scrollToPage(page: 1, animated: true)
    }
    
    @IBAction func bookmarkedButtonTapped(sender: UIButton) {
        self.resetSegmentedButton()
        
        sender.backgroundColor = UIColor.black
        sender.setTitleColor(UIColor.appBlueColor(), for: .normal)
        
        self.scrollView.scrollToPage(page: 2, animated: true)
    }
}
