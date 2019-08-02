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
    
    var bars: [Bar] = []
    
    var selectedPreferences: [Category] = []
    
    var selectedStandardOffers: [StandardOffer] = []

    var shouldHidePreferenceButton: Bool = false
    
    let locationManager = MyLocationManager()
    
    var markers: [GMSMarker] = []
    
    var scopeItems: [SearchScopeItem] = SearchScope.allItems()
    var selectedScopeItem: SearchScopeItem?
    
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
        
//        self.setUpStatefulTableView()
//
//        self.mapView.delegate = self
        
        self.setUserLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(barDetailsRefreshedNotification(notification:)), name: notificationNameBarDetailsRefreshed, object: nil)
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
        NotificationCenter.default.removeObserver(self, name: notificationNameBarDetailsRefreshed, object: nil)
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
    
    func resetCurrentData() {
//        self.bars.removeAll()
//        self.statefulTableView.reloadData()
    }
    
    func reset() {
//        self.dataRequest?.cancel()
//        self.resetCurrentData()
//
//        self.statefulTableView.triggerInitialLoad()
    }
    
    func setUpMarkers() {
        
//        self.mapView.clear()
//        self.markers.removeAll()
//
//        var bounds = GMSCoordinateBounds()
//        for (index, bar) in self.bars.enumerated() {
//            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(bar.latitude.value), longitude: CLLocationDegrees(bar.longitude.value))
//
//            bounds = bounds.includingCoordinate(location.coordinate)
//
//            let pinImage = self.getPinImage(explore: bar)
//            let marker = self.createMapMarker(location: location, pinImage: pinImage)
//            marker.userData = bar
//            marker.zIndex = Int32(index)
//            marker.map = self.mapView
//
//            self.markers.append(marker)
//        }
        
    }
    
    func getPinImage(explore: Bar) -> UIImage {
        var pinImage = UIImage(named: "icon_pin_gold")!
        if let timings = explore.timings.value {
            if timings.dayStatus == .opened {
                if timings.isOpen.value {
                    if let activeStandardOffer = explore.activeStandardOffer.value {
                        pinImage = Utility.shared.getPinImage(offerType: activeStandardOffer.type)
                    } else {
                        pinImage = UIImage(named: "icon_pin_grayed")!
                    }
                } else {
                    pinImage = UIImage(named: "icon_pin_grayed")!
                }
            } else {
                pinImage = UIImage(named: "icon_pin_grayed")!
            }
            
        } else {
            pinImage = UIImage(named: "icon_pin_grayed")!
        }
        
        return pinImage
    }
    
    func createMapMarker(location: CLLocation, pinImage: UIImage) -> GMSMarker {
        let marker = GMSMarker(position: location.coordinate)
        let iconImage = pinImage
        let markerView = UIImageView(image: iconImage)
        marker.iconView = markerView
        return marker
    }
    
//    func setUpStatefulTableView() {
//        
//        self.statefulTableView.backgroundColor = .clear
//        for aView in self.statefulTableView.subviews {
//            aView.backgroundColor = .clear
//        }
//        
//        self.statefulTableView.canLoadMore = false
//        self.statefulTableView.canPullToRefresh = false
//        self.statefulTableView.innerTable.rowHeight = UITableViewAutomaticDimension
//        self.statefulTableView.innerTable.estimatedRowHeight = 250.0
//        self.statefulTableView.innerTable.tableFooterView = UIView()
//        self.statefulTableView.innerTable.separatorStyle = .none
//        
//        self.statefulTableView.innerTable.register(cellType: BarTableViewCell.self)
//        self.statefulTableView.innerTable.delegate = self
//        self.statefulTableView.innerTable.dataSource = self
//        self.statefulTableView.statefulDelegate = self
//        
//        for aView in self.statefulTableView.innerTable.subviews {
//            if aView.isMember(of: UIRefreshControl.self) {
//                aView.removeFromSuperview()
//                break
//            }
//        }
//    }
    
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
    
    func setupMapCamera(cordinate: CLLocationCoordinate2D) {
//        let position = GMSCameraPosition.camera(withTarget: cordinate, zoom: 15.0)
//        self.mapView.animate(to: position)
//        self.mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
//
//        if CLLocationManager.authorizationStatus() != .notDetermined {
//            self.mapView.settings.myLocationButton = true
//            self.mapView.isMyLocationEnabled = true
//        }
    }
    
    func setUserLocation() {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        var canContinue: Bool? = nil
        if authorizationStatus == .authorizedAlways {
            canContinue = true
        } else if authorizationStatus == .authorizedWhenInUse {
            canContinue = false
        }
        
        guard let requestAlwaysAccess = canContinue else {
            debugPrint("Location permission not authorized")
            self.setupMapCamera(cordinate: defaultUKLocation)
            return
        }
        
        self.locationManager.locationPreferenceAlways = requestAlwaysAccess
        self.locationManager.requestLocation(desiredAccuracy: kCLLocationAccuracyBestForNavigation, timeOut: 20.0) { [unowned self] (location, error) in
            
            guard error == nil else {
                debugPrint("Error while getting location: \(error!.localizedDescription)")
                self.setupMapCamera(cordinate: defaultUKLocation)
                return
            }
            
            if let location = location {
                if let user = Utility.shared.getCurrentUser() {
                    try! CoreStore.perform(synchronous: { (transaction) -> Void in
                        let edittedUser = transaction.edit(user)
                        edittedUser?.latitude.value = location.coordinate.latitude
                        edittedUser?.longitude.value = location.coordinate.longitude
                        
                    })
                }
                self.setupMapCamera(cordinate: location.coordinate)
            }
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
    
    @IBAction func cancelBarButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
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

//MARK: UITableViewDataSource, UITableViewDelegate
/*
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.searchBar.resignFirstResponder()
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: BarTableViewCell.self)
        cell.setUpCell(bar: self.bars[indexPath.row])
        cell.delegate = self
        cell.exploreBaseDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let aCell = cell as? BarTableViewCell {
            aCell.scrollToCurrentImage()
            
            let bar = self.bars[indexPath.row]
            let imageCount = bar.images.value.count
            
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let aCell = cell as? BarTableViewCell {
            aCell.pagerView.automaticSlidingInterval = 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        self.moveToBarDetail(bar: self.bars[indexPath.row])
    }
}

//MARK: ExploreBaseTableViewCellDelegate
extension SearchViewController: ExploreBaseTableViewCellDelegate {
    func exploreBaseTableViewCell(cell: ExploreBaseTableViewCell, didSelectItem itemIndexPath: IndexPath) {
        guard let tableCellIndexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        self.moveToBarDetail(bar: self.bars[tableCellIndexPath.row])
    }
}
*/

//MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        
        self.resetSearchScopeControllers()
    }
}

//MARK: BarDetailViewControllerDelegate
extension SearchViewController: BarDetailViewControllerDelegate {
    func barDetailViewController(controller: BarDetailViewController, cancelButtonTapped sender: UIBarButtonItem) {
    }
}

/*
//MARK: BarTableViewCellDelegare
extension SearchViewController: BarTableViewCellDelegare {
    func barTableViewCell(cell: BarTableViewCell, favouriteButton sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let bar = self.bars[indexPath.row]
        markFavourite(bar: bar, cell: cell)
    }
    
    func barTableViewCell(cell: BarTableViewCell, distanceButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let bar = self.bars[indexPath.row]
        self.showDirection(bar: bar)
    }
}

//MARK: StatefulTableDelegate
extension SearchViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        
        self.resetCurrentData()
        self.getBars(isRefreshing: false) {  [unowned self] (error) in
            handler(self.bars.count == 0, error)
        }
        
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.getBars(isRefreshing: false) { (error) in
            handler(false, error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getBars(isRefreshing: true) { [unowned self] (error) in
            handler(self.bars.count == 0, error)
        }
    }
    
    func statefulTableViewViewForInitialLoad(tvc: StatefulTableView) -> UIView? {
        let initialErrorView = LoadingAndErrorView.loadFromNib()
        initialErrorView.backgroundColor = .clear
        initialErrorView.showLoading()
        return initialErrorView
    }
    
    func statefulTableViewInitialErrorView(tvc: StatefulTableView, forInitialLoadError: NSError?) -> UIView? {
        if forInitialLoadError == nil {
            let title = "No Search Result Found"
            let subTitle = "Tap to refresh"
            
            let emptyDataView = EmptyDataView.loadFromNib()
            emptyDataView.setTitle(title: title, desc: subTitle, iconImageName: "icon_loading", buttonTitle: "")
            
            emptyDataView.actionHandler = { (sender: UIButton) in
                tvc.triggerInitialLoad()
            }
            
            return emptyDataView
            
        } else {
            let initialErrorView = LoadingAndErrorView.loadFromNib()
            initialErrorView.showErrorView(canRetry: true)
            initialErrorView.backgroundColor = .clear
            initialErrorView.showErrorViewWithRetry(errorMessage: forInitialLoadError!.localizedDescription, reloadMessage: "Tap to refresh")
            
            initialErrorView.retryHandler = {(sender: UIButton) in
                tvc.triggerInitialLoad()
            }
            
            return initialErrorView
        }
    }
    
    func statefulTableViewLoadMoreErrorView(tvc: StatefulTableView, forLoadMoreError: NSError?) -> UIView? {
        let loadingView = LoadingAndErrorView.loadFromNib()
        loadingView.showErrorView(canRetry: true)
        loadingView.backgroundColor = .clear
        
        if forLoadMoreError == nil {
            loadingView.showLoading()
        } else {
            loadingView.showErrorViewWithRetry(errorMessage: forLoadMoreError!.localizedDescription, reloadMessage: "Tap to refresh")
        }
        
        loadingView.retryHandler = {(sender: UIButton) in
            tvc.triggerLoadMore()
        }
        
        return loadingView
    }
}

//MARK: Webservices Methods
extension SearchViewController {
    func getBars(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {

        self.dataRequest?.cancel()
        
        var params:[String : Any] =  ["type": self.searchType.rawValue,
                                      "pagination" : false,
                                      "keyword" : self.searchBar.text!]
        
        if self.selectedPreferences.count > 0 {
            let ids = self.selectedPreferences.map({$0.id.value})
            params["interest_ids"] = ids
        }
        
        if self.selectedStandardOffers.count > 0 {
            let ids = self.selectedStandardOffers.map({$0.id.value})
            params["tier_ids"] = ids
        }
        
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiEstablishment, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                completion(error! as NSError)
                return
            }
            
            guard serverError == nil else {
                completion(serverError!.nsError())
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                
                self.bars.removeAll()
                var importedObjects: [Bar] = []
                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                    let objects = try! transaction.importUniqueObjects(Into<Bar>(), sourceArray: responseArray)
                    importedObjects.append(contentsOf: objects)
                })
                
                for object in importedObjects {
                    let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
                    self.bars.append(fetchedObject!)
                }
                
                self.statefulTableView.innerTable.reloadData()
                self.setUpMarkers()

                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
    
    func markFavourite(bar: Bar, cell: BarTableViewCell) {
        
        debugPrint("isFav == \(bar.isUserFavourite.value)")
        
        let params:[String : Any] = ["establishment_id": bar.id.value,
                                     "is_favorite" : !(bar.isUserFavourite.value)]
        
        try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
            if let bars = transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), bar.id.value)) {
                for bar in bars {
                    bar.isUserFavourite.value = !bar.isUserFavourite.value
                }
            }
        })
        
        cell.setUpCell(bar: bar)
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiUpdateFavorite, method: .put) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("error == \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard serverError == nil else {
                debugPrint("servererror == \(String(describing: serverError?.errorMessages()))")
                return
            }
            
            let response = response as! [String : Any]
            let responseDict = response["response"] as! [String : Any]
            
            if let responseID = (responseDict["data"] as? Int) {
                debugPrint("responseID == \(responseID)")
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("genericError == \(String(describing: genericError.localizedDescription))")
            }
        }
    }
}
*/

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

//Notification Methods
extension SearchViewController {
    @objc func barDetailsRefreshedNotification(notification: Notification) {
        
        let bar = notification.object as! Bar
        
        let barMarkers = self.markers.filter { (marker) -> Bool in
            if let data = marker.userData as? Bar {
                return data.id.value == bar.id.value
            }
            
            return false
        }
        
        guard barMarkers.count > 0 else {
            return
        }
        
        for marker in barMarkers {
            marker.map = nil
        }
        
        self.markers.removeAll { (marker) -> Bool in
            if let data = marker.userData as? Bar {
                return data.id.value == bar.id.value
            }
            
            return false
        }
        
        let location: CLLocation = CLLocation(latitude: CLLocationDegrees(bar.latitude.value), longitude: CLLocationDegrees(bar.longitude.value))
        
        let pinImage = self.getPinImage(explore: bar)
        let marker = self.createMapMarker(location: location, pinImage: pinImage)
        marker.userData = bar
//        marker.map = mapView
        
        self.markers.append(marker)
        
        marker.zIndex = Int32(self.markers.count - 1)
        
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

