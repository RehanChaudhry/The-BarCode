//
//  SearchViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 09/11/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import Alamofire
import CoreStore
import GoogleMaps
import CoreLocation
import PureLayout
import ObjectMapper
import HTTPStatusCodes

class SearchViewController: UIViewController {

    @IBOutlet var containerView: UIView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var mapButton: UIButton!
    @IBOutlet var listButton: UIButton!
    @IBOutlet var preferencesButton: UIButton!
    @IBOutlet var standardOfferButton: UIButton!
    
    @IBOutlet var cancelButton: UIButton!
    
    @IBOutlet var searchbarLeft: NSLayoutConstraint!
    @IBOutlet var searchbarRight: NSLayoutConstraint!
    
    @IBOutlet var tempView: UIView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var snackBarContainer: UIView!
    
    var bars: [Bar] = []
    
    var selectedPreferences: [Category] = []
    var filteredPreferences: [Category] = []
    
    var selectedStandardOffers: [StandardOffer] = []
    var selectedRedeemingType: RedeemingTypeModel?
    
    var shouldHidePreferenceButton: Bool = false
    
    var scopeItems: [SearchScopeItem] = SearchScope.allItems()
    var selectedScopeItem: SearchScopeItem?
    
    var pageViewController: UIPageViewController!
    
    var isViewAlreadyLoaded: Bool = false
    
    var lastSearchQuery: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        if self.selectedScopeItem == nil {
            self.selectedScopeItem = self.scopeItems.first
            self.selectedScopeItem?.isSelected = true
        }
        
        self.listButton.roundCorners(corners: [.topLeft, .bottomLeft], radius: 5.0)
        self.mapButton.roundCorners(corners: [.topRight, .bottomRight], radius: 5.0)
        
        self.collectionView.register(cellType: SearchScopeCell.self)
        
        if self.shouldHidePreferenceButton {
            self.preferencesButton.isHidden = true
            self.searchbarRight.constant = -44.0
        }
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.appGrayColor()
        textFieldInsideSearchBar?.keyboardAppearance = .dark
        
        self.resetMapListSegment()
        self.listButton.backgroundColor = UIColor.black
        self.listButton.tintColor = UIColor.appBlueColor()
        
        self.standardOfferButton.backgroundColor = self.tempView.backgroundColor
        self.standardOfferButton.tintColor = UIColor.appGrayColor()
        
        self.preferencesButton.backgroundColor = self.tempView.backgroundColor
        self.preferencesButton.tintColor = UIColor.appGrayColor()
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [:])
        self.pageViewController.view.backgroundColor = UIColor.clear
        self.pageViewController.dataSource = self
        self.pageViewController.delegate = self
        
        self.addChildViewController(self.pageViewController)
        self.pageViewController.willMove(toParentViewController: self)
        self.containerView.addSubview(self.pageViewController.view)
        
        self.pageViewController.view.autoPinEdgesToSuperviewEdges()
        
        for aView in self.pageViewController.view.subviews {
            aView.backgroundColor = UIColor.clear
            if let scrollView = aView as? UIScrollView {
                scrollView.isScrollEnabled = false
            }
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.setUpPreferencesButton()
        self.setUpStandardOfferButton()
        
        //WORKAROUND: If we load it in viewdidload, map view center get disturbed
        if !self.isViewAlreadyLoaded {
            self.isViewAlreadyLoaded = true
            
            self.setupSearchController()
        }
        
        for scope in self.scopeItems {
            scope.controller.statefulTableView.innerTable.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        debugPrint("Did receive memory warning")
    }
    
    deinit {
        debugPrint("searchviewcontroller deinit called")
    }
    
    //MARK: My Methods
    
    func setupSearchController() {
        for scopeItem in self.scopeItems {
            scopeItem.controller.view.backgroundColor = UIColor.clear
            scopeItem.controller.baseDelegate = self
            scopeItem.controller.setUpStatefulTableView()
        }
        
        let allSearchViewController = self.scopeItems.map{$0.controller}.first! as! AllSearchViewController
        allSearchViewController.allSearchDelegate = self
        
        let indexPath = IndexPath(item: 0, section: 0)
        self.forcefullySelectScopeItemAt(indexPath: indexPath, direction: .forward, animated: false)
        self.resetSearchScopeControllers()
    }
    
    func resetMapListSegment() {
        self.mapButton.backgroundColor = self.tempView.backgroundColor
        self.listButton.backgroundColor = self.tempView.backgroundColor
        
        self.mapButton.tintColor = UIColor.appGrayColor()
        self.listButton.tintColor = UIColor.appGrayColor()
    }
    
    func setUpPreferencesButton() {
        if self.selectedPreferences.count > 0 {
            self.preferencesButton.backgroundColor = UIColor.black
            self.preferencesButton.tintColor = UIColor.appBlueColor()
        } else {
            self.preferencesButton.backgroundColor = self.tempView.backgroundColor
            self.preferencesButton.tintColor = UIColor.appGrayColor()
        }
        
    }
    
    func setUpStandardOfferButton() {
        if self.selectedStandardOffers.count > 0 || self.selectedRedeemingType != nil {
            self.standardOfferButton.backgroundColor = UIColor.black
            self.standardOfferButton.tintColor = UIColor.appBlueColor()
        } else {
            self.standardOfferButton.backgroundColor = self.tempView.backgroundColor
            self.standardOfferButton.tintColor = UIColor.appGrayColor()
        }
    }
    
    func showDirection(bar: Bar) {
        let mapUrl = "https://www.google.com/maps/dir/?api=1&destination=\(bar.latitude.value)+\(bar.longitude.value)"
        UIApplication.shared.open(URL(string: mapUrl)!, options: [:]) { (success) in
            
        }
    }
    
    func resetSearchScopeControllers() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let voucherTitle = appDelegate.voucherTitle {
            self.searchBar.text = voucherTitle
            appDelegate.voucherTitle = nil
            
            //Forcefully select deal scoope
            if let index = self.scopeItems.firstIndex(where: { $0.scopeType == .deal }) {
                let indexPath = IndexPath(row: index, section: 0)
                self.selectScope(indexPath: indexPath)
            }
        }
        
        for scope in self.scopeItems {
            scope.controller.selectedPreferences = self.filteredPreferences
            scope.controller.selectedStandardOffers = self.selectedStandardOffers
            scope.controller.selectedRedeemingType = self.selectedRedeemingType
            scope.controller.shouldReset = true
            scope.controller.prepareToReset()
            scope.controller.keyword = self.searchBar.text ?? ""
        }
        
        self.selectedScopeItem?.controller.reset()
        self.selectedScopeItem?.controller.setUpMapViewForLocations()
        self.selectedScopeItem?.controller.shouldReset = false
    }
    
    //MARK: My IBActions
    @IBAction func listButtonTapped(sender: UIButton) {
        self.resetMapListSegment()
        
        sender.backgroundColor = UIColor.black
        sender.tintColor = UIColor.appBlueColor()
        
        for scope in self.scopeItems {
            scope.controller.showListView(animted: true)
        }
    }
    
    @IBAction func mapButtonTapped(sender: UIButton) {
        self.resetMapListSegment()
        
        sender.backgroundColor = UIColor.black
        sender.tintColor = UIColor.appBlueColor()
        
        for scope in self.scopeItems {
            scope.controller.showMapView(animted: true)
        }
        
        self.searchBar.resignFirstResponder()
    }
    
    @IBAction func preferencesButtonTapped(sender: UIButton) {
        let categoriesController = self.storyboard?.instantiateViewController(withIdentifier: "CategoryFilterViewController") as! CategoryFilterViewController
        categoriesController.preSelectedCategories = self.selectedPreferences
        categoriesController.delegate = self
        self.navigationController?.pushViewController(categoriesController, animated: true)
    }
    
    @IBAction func standardOfferButtonTapped(sender: UIButton) {
        let standardOfferController = self.storyboard!.instantiateViewController(withIdentifier: "StandardOffersViewController") as! StandardOffersViewController
        standardOfferController.preSelectedTiers = self.selectedStandardOffers
        standardOfferController.preSelectedRedeemingType = self.selectedRedeemingType
        standardOfferController.delegate = self
        self.navigationController?.pushViewController(standardOfferController, animated: true)
    }
    
    @IBAction func cancelButtonTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        if self.lastSearchQuery != searchBar.text! {
            self.lastSearchQuery = searchBar.text!
            self.resetSearchScopeControllers()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        UIView.animate(withDuration: 0.25) {
            
            self.standardOfferButton.alpha = 0.0
            self.preferencesButton.alpha = 0.0
            self.mapButton.alpha = 0.0
            self.listButton.alpha = 0.0
            self.cancelButton.alpha = 0.0
            
            self.searchbarRight.constant = -164.0
            self.searchbarLeft.constant = -self.cancelButton.frame.size.width + 8.0
            self.view.layoutIfNeeded()
        }
    }
    
    //typeahead functionality 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.lastSearchQuery = searchBar.text!
        self.resetSearchScopeControllers()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
        UIView.animate(withDuration: 0.25) {
            
            self.standardOfferButton.alpha = 1.0
            self.preferencesButton.alpha = 1.0
            self.mapButton.alpha = 1.0
            self.listButton.alpha = 1.0
            self.cancelButton.alpha = 1.0
            
            self.searchbarRight.constant = 6.0
            self.searchbarLeft.constant = -8.0
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

//MARK: BarDetailViewControllerDelegate
extension SearchViewController: BarDetailViewControllerDelegate {
    func barDetailViewController(controller: BarDetailViewController, cancelButtonTapped sender: UIBarButtonItem) {
        
    }
}

//MARK: CategoriesViewControllerDelegate
extension SearchViewController: CategoryFilterViewControllerDelegate {
    func categoryFilterViewController(controller: CategoryFilterViewController, didSelectPrefernces selectedPreferences: [Category], filteredPreferences: [Category]) {
        
        self.selectedPreferences = selectedPreferences
        self.filteredPreferences = filteredPreferences

        if !self.isViewAlreadyLoaded {
            self.isViewAlreadyLoaded = true
            
            self.setupSearchController()
        }
        
        self.resetSearchScopeControllers()
    }
}

//MARK: StandardOffersViewControllerDelegate
extension SearchViewController: StandardOffersViewControllerDelegate {
    func standardOffersViewController(controller: StandardOffersViewController, didSelectStandardOffers selectedOffers: [StandardOffer], redeemingType: RedeemingTypeModel?) {
        
        self.selectedRedeemingType = redeemingType
        self.selectedStandardOffers = selectedOffers
        
        if !self.isViewAlreadyLoaded {
            self.isViewAlreadyLoaded = true
            
            self.setupSearchController()
        }
        
        self.resetSearchScopeControllers()
    }
}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.scopeItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: SearchScopeCell.self)
        cell.setupCell(searchScope: self.scopeItems[indexPath.item], tempViewBGColor: self.tempView.backgroundColor!)
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 4 || indexPath.row == 5 {
            return CGSize(width: 150, height: 43.0)
        }else {
            return CGSize(width: 100, height: 43.0)
        }
    }
}

//MARK: SearchScopeCellDelegate
extension SearchViewController: SearchScopeCellDelegate {
    func searchScopeCell(cell: SearchScopeCell, scopeButtonTapped sender: UIButton) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        self.selectScope(indexPath: indexPath)
        
        self.view.endEditing(true)
    }
    
    func selectScope(indexPath: IndexPath) {
        
        let currentController = self.pageViewController.viewControllers![0]
        let indexOfCurrentController = self.scopeItems.firstIndex(where: {$0.controller == currentController})!
        
        guard indexOfCurrentController != indexPath.item else {
            debugPrint("Already showing the controller")
            return
        }
        
        let direction = indexPath.item > indexOfCurrentController ? UIPageViewControllerNavigationDirection.forward : .reverse
        self.forcefullySelectScopeItemAt(indexPath: indexPath, direction: direction, animated: true)
    }
    
    func forcefullySelectScopeItemAt(indexPath: IndexPath, direction: UIPageViewControllerNavigationDirection, animated: Bool) {
        
        for scope in self.scopeItems {
            scope.isSelected = false
        }
        
        self.selectedScopeItem = self.scopeItems[indexPath.item]
        self.selectedScopeItem?.isSelected = true
        self.collectionView.reloadData()
        
        self.pageViewController.setViewControllers([self.selectedScopeItem!.controller], direction: direction, animated: animated) { (completed: Bool) in
            
        }
        
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        
        if self.selectedScopeItem?.controller.shouldReset == true {
            self.selectedScopeItem?.controller.reset()
            self.selectedScopeItem?.controller.setUpMapViewForLocations()
            self.selectedScopeItem?.controller.shouldReset = false
        }
    }
}

//MARK: BaseSearchScopeViewControllerDelegate
extension SearchViewController: BaseSearchScopeViewControllerDelegate {
    
    func baseSearchScopeViewController(controller: BaseSearchScopeViewController, moveToBarDetails barId: String, scopeType: SearchScope, dealsSubType: BarDetailDealsPreSelectedSubTabType) {
        
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
        barDetailNav.modalPresentationStyle = .fullScreen
        
        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
        barDetailController.barId = barId
        barDetailController.delegate = self
        
        if scopeType == .bar {
            barDetailController.preSelectedTabIndex = 0
            barDetailController.preSelectedSubTabIndexWhatsOn = 0
            barDetailController.preSelectedSubTabIndexOffers = 0
        } else if scopeType == .deal {
            
            barDetailController.preSelectedTabIndex = 2
            barDetailController.preSelectedSubTabIndexWhatsOn = 0
            barDetailController.preSelectedSubTabIndexOffers = 1
            
            if dealsSubType == .chalkboard {
                barDetailController.preSelectedSubTabIndexOffers = 0
            } else if dealsSubType == .exclusive {
                barDetailController.preSelectedSubTabIndexOffers = 1
            }
            
        } else if scopeType == .liveOffer {
            barDetailController.preSelectedTabIndex = 2
            barDetailController.preSelectedSubTabIndexWhatsOn = 0
            barDetailController.preSelectedSubTabIndexOffers = 2
        } else if scopeType == .food || scopeType == .delivery {
            barDetailController.preSelectedTabIndex = 1
            barDetailController.preSelectedSubTabIndexWhatsOn = 0
            barDetailController.preSelectedSubTabIndexOffers = 0
        } else if scopeType == .drink {
            barDetailController.preSelectedTabIndex = 1
            barDetailController.preSelectedSubTabIndexWhatsOn = 1
            barDetailController.preSelectedSubTabIndexOffers = 0
        } else if scopeType == .event {
            barDetailController.preSelectedTabIndex = 2
            barDetailController.preSelectedSubTabIndexWhatsOn = 2
            barDetailController.preSelectedSubTabIndexOffers = 2
        }
        
        self.present(barDetailNav, animated: true, completion: nil)
    }
    
    func baseSearchScopeViewController(controller: BaseSearchScopeViewController, refreshSnackBar refresh: Bool) {

    }
    
    func baseSearchScopeViewController(controller: BaseSearchScopeViewController, scrollViewDidScroll scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

//MARK: AllSearchViewControllerDelegate
extension SearchViewController: AllSearchViewControllerDelegate {
    func allSearchViewController(controller: AllSearchViewController, viewMoreButtonTapped type: AllSearchItemType) {
        if type == .bar, let index = self.scopeItems.firstIndex(where: { $0.scopeType == .bar }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.selectScope(indexPath: indexPath)
        } else if type == .deliveryBars, let index = self.scopeItems.firstIndex(where: { $0.scopeType == .delivery }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.selectScope(indexPath: indexPath)
        } else if type == .deal, let index = self.scopeItems.firstIndex(where: { $0.scopeType == .deal }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.selectScope(indexPath: indexPath)
        } else if type == .liveOffer, let index = self.scopeItems.firstIndex(where: { $0.scopeType == .liveOffer }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.selectScope(indexPath: indexPath)
        } else if type == .food, let index = self.scopeItems.firstIndex(where: { $0.scopeType == .food }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.selectScope(indexPath: indexPath)
        } else if type == .drink, let index = self.scopeItems.firstIndex(where: { $0.scopeType == .drink }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.selectScope(indexPath: indexPath)
        } else if type == .event, let index = self.scopeItems.firstIndex(where: { $0.scopeType == .event }) {
            let indexPath = IndexPath(row: index, section: 0)
            self.selectScope(indexPath: indexPath)
        }
    }
}

//MARK: UIPageViewControllerDelegate
extension SearchViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        debugPrint("pending controllers: \(previousViewControllers)")
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        debugPrint("pending controllers: \(pendingViewControllers)")
    }
}

//MARK: UIPageViewControllerDataSource
extension SearchViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if let index = self.scopeItems.firstIndex(where: {$0.controller == viewController}), (index - 1) >= 0 {
            return (self.scopeItems[index - 1]).controller
        } else {
            return nil
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.scopeItems.firstIndex(where: {$0.controller == viewController}), ((index + 1) < self.scopeItems.count) {
            return (self.scopeItems[index + 1]).controller
        } else {
            return nil
        }
    }
}
