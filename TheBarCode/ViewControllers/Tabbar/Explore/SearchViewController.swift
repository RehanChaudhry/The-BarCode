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

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var scrollContainerView: UIView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var mapButton: UIButton!
    @IBOutlet var listButton: UIButton!
    @IBOutlet var preferencesButton: UIButton!
    @IBOutlet var standardOfferButton: UIButton!
    
    @IBOutlet var searchbarRight: NSLayoutConstraint!
    
    @IBOutlet var tempView: UIView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var snackBarContainer: UIView!
    
    var bars: [Bar] = []
    
    var selectedPreferences: [Category] = []
    
    var selectedStandardOffers: [StandardOffer] = []

    var shouldHidePreferenceButton: Bool = false
    
    var scopeItems: [SearchScopeItem] = SearchScope.allItems()
    var selectedScopeItem: SearchScopeItem?
    
    var snackBarController: ReloadSnackBarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.selectedScopeItem == nil {
            self.selectedScopeItem = self.scopeItems.first
            self.selectedScopeItem?.isSelected = true
        }
        
        self.setupSearchController()
        
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

        self.resetSearchScopeControllers()
        
        self.snackBarController = (self.storyboard!.instantiateViewController(withIdentifier: "ReloadSnackBarViewController") as! ReloadSnackBarViewController)
        self.addChildViewController(self.snackBarController)
        self.snackBarController.willMove(toParentViewController: self)
        self.snackBarContainer.addSubview(self.snackBarController.view)
        self.snackBarController.view.autoPinEdgesToSuperviewEdges()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.setUpPreferencesButton()
        self.setUpStandardOfferButton()
        
        for scope in self.scopeItems {
            scope.controller.statefulTableView.innerTable.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    deinit {
        debugPrint("searchviewcontroller deinit called")
    }
    
    //MARK: My Methods
    func setupSearchController() {
        for scope in self.scopeItems {
            let controller = scope.controller
            controller.view.backgroundColor = UIColor.clear
            self.contentView.addSubview(controller.view)
            
            controller.view.autoPinEdge(ALEdge.top, to: ALEdge.top, of: self.contentView)
            controller.view.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: self.contentView)

            controller.view.autoMatch(ALDimension.width, to: ALDimension.width, of: self.scrollContainerView)
            controller.view.autoMatch(ALDimension.height, to: ALDimension.height, of: self.scrollContainerView)

            if let lastController = self.childViewControllers.last {
                controller.view.autoPinEdge(ALEdge.left, to: ALEdge.right, of: lastController.view)
            } else {
                controller.view.autoPinEdge(ALEdge.left, to: ALEdge.left, of: self.contentView)
            }

            if scope == self.scopeItems.last {
                controller.view.autoPinEdge(ALEdge.right, to: ALEdge.right, of: self.contentView)
            }

            self.addChildViewController(controller)
            controller.willMove(toParentViewController: self)
            controller.baseDelegate = self
            controller.setUpStatefulTableView()
            
            if let controller = controller as? AllSearchViewController {
                controller.allSearchDelegate = self
            }
        }
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
        if self.selectedStandardOffers.count > 0 {
            self.standardOfferButton.backgroundColor = UIColor.black
            self.standardOfferButton.tintColor = UIColor.appBlueColor()
        } else {
            self.standardOfferButton.backgroundColor = self.tempView.backgroundColor
            self.standardOfferButton.tintColor = UIColor.appGrayColor()
        }
    }
    
    func moveToBarDetail(bar: Bar) {
//        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
//        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
//        barDetailController.selectedBar = bar
//        barDetailController.delegate = self
//
//        switch self.searchType {
//        case .liveOffers:
//            barDetailController.preSelectedTabIndex = 2
//        case .deals:
//            barDetailController.preSelectedTabIndex = 1
//        default:
//            barDetailController.preSelectedTabIndex = 0
//        }
//
//        self.present(barDetailNav, animated: true, completion: nil)
    }
    
    func showDirection(bar: Bar) {
        let user = Utility.shared.getCurrentUser()!

        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let source = CLLocationCoordinate2D(latitude: user.latitude.value, longitude: user.longitude.value)
            
            let urlString = String(format: "comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=driving",source.latitude,source.longitude,bar.latitude.value,bar.longitude.value)
            let url = URL(string: urlString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            let url = URL(string: "https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    func resetSearchScopeControllers() {
        for scope in self.scopeItems {
            scope.controller.selectedPreferences = self.selectedPreferences
            scope.controller.selectedStandardOffers = self.selectedStandardOffers
            scope.controller.shouldReset = true
            scope.controller.prepareToReset()
            scope.controller.keyword = self.searchBar.text ?? ""
        }
        
        self.selectedScopeItem?.controller.reset()
        self.selectedScopeItem?.controller.shouldReset = false
    }
    
    //MARK: My IBActions
    @IBAction func listButtonTapped(sender: UIButton) {
        self.resetMapListSegment()
        
        sender.backgroundColor = UIColor.black
        sender.tintColor = UIColor.appBlueColor()
        
        for scope in self.scopeItems {
            scope.controller.showListView()
        }
    }
    
    @IBAction func mapButtonTapped(sender: UIButton) {
        self.resetMapListSegment()
        
        sender.backgroundColor = UIColor.black
        sender.tintColor = UIColor.appBlueColor()
        
        for scope in self.scopeItems {
            scope.controller.showMapView()
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
        standardOfferController.delegate = self
        self.navigationController?.pushViewController(standardOfferController, animated: true)
    }
}

//MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        self.resetSearchScopeControllers()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        UIView.animate(withDuration: 0.25) {
            
            self.standardOfferButton.alpha = 0.0
            self.preferencesButton.alpha = 0.0
            self.mapButton.alpha = 0.0
            self.listButton.alpha = 0.0
            
            self.searchbarRight.constant = -164.0
            self.view.layoutIfNeeded()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
        UIView.animate(withDuration: 0.25) {
            
            self.standardOfferButton.alpha = 1.0
            self.preferencesButton.alpha = 1.0
            self.mapButton.alpha = 1.0
            self.listButton.alpha = 1.0
            
            self.searchbarRight.constant = 0.0
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
    func categoryFilterViewController(controller: CategoryFilterViewController, didSelectPrefernces selectedPreferences: [Category]) {
        self.selectedPreferences = selectedPreferences
        self.resetSearchScopeControllers()
    }
}

//MARK: StandardOffersViewControllerDelegate
extension SearchViewController: StandardOffersViewControllerDelegate {
    func standardOffersViewController(controller: StandardOffersViewController, didSelectStandardOffers selectedOffers: [StandardOffer]) {
        self.selectedStandardOffers = selectedOffers
        self.resetSearchScopeControllers()
    }
}

//MARK: GMSMapViewDelegate
extension SearchViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let bar = marker.userData as! Bar
        self.moveToBarDetail(bar: bar)
        return false
    }
}

//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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
}

//MARK: SearchScopeCellDelegate
extension SearchViewController: SearchScopeCellDelegate {
    func searchScopeCell(cell: SearchScopeCell, scopeButtonTapped sender: UIButton) {
        guard let indexPath = self.collectionView.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        self.selectScope(indexPath: indexPath)
        
    }
    
    func selectScope(indexPath: IndexPath) {
        for scope in self.scopeItems {
            scope.isSelected = false
        }
        
        self.selectedScopeItem = self.scopeItems[indexPath.item]
        self.selectedScopeItem?.isSelected = true
        self.collectionView.reloadData()
        
        self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.scrollView.scrollToPage(page: indexPath.item, animated: true)
        
        if self.selectedScopeItem?.controller.shouldReset == true {
            self.selectedScopeItem?.controller.reset()
            self.selectedScopeItem?.controller.shouldReset = false
        }
    }
}

//MARK: BaseSearchScopeViewControllerDelegate
extension SearchViewController: BaseSearchScopeViewControllerDelegate {
    func baseSearchScopeViewController(controller: BaseSearchScopeViewController, moveToBarDetails barId: String, scopeType: SearchScope) {
        
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
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
        } else if scopeType == .liveOffer {
            barDetailController.preSelectedTabIndex = 2
            barDetailController.preSelectedSubTabIndexWhatsOn = 0
            barDetailController.preSelectedSubTabIndexOffers = 2
        } else if scopeType == .food {
            barDetailController.preSelectedTabIndex = 1
            barDetailController.preSelectedSubTabIndexWhatsOn = 2
            barDetailController.preSelectedSubTabIndexOffers = 0
        } else if scopeType == .drink {
            barDetailController.preSelectedTabIndex = 1
            barDetailController.preSelectedSubTabIndexWhatsOn = 1
            barDetailController.preSelectedSubTabIndexOffers = 0
        } else if scopeType == .event {
            barDetailController.preSelectedTabIndex = 1
            barDetailController.preSelectedSubTabIndexWhatsOn = 0
            barDetailController.preSelectedSubTabIndexOffers = 0
        }
        
        self.present(barDetailNav, animated: true, completion: nil)
    }
    
    func baseSearchScopeViewController(controller: BaseSearchScopeViewController, refreshSnackBar refresh: Bool) {
        self.snackBarController.getReloadStatus()
    }
}

//MARK: AllSearchViewControllerDelegate
extension SearchViewController: AllSearchViewControllerDelegate {
    func allSearchViewController(controller: AllSearchViewController, viewMoreButtonTapped type: AllSearchItemType) {
        if type == .bar, let index = self.scopeItems.firstIndex(where: { $0.scopeType == .bar }) {
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

