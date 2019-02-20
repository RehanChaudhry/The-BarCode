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

class SearchViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var listContainer: UIView!
    @IBOutlet var mapContainer: UIView!
    
    @IBOutlet var statefulTableView: StatefulTableView!
    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var mapButton: UIButton!
    @IBOutlet var listButton: UIButton!
    @IBOutlet var preferencesButton: UIButton!
    @IBOutlet var standardOfferButton: UIButton!
    
    @IBOutlet var searchbarRight: NSLayoutConstraint!
    
    @IBOutlet var tempView: UIView!
    
    var bars: [Bar] = []
    
    var dataRequest: DataRequest?
    
    var displayType: DisplayType = .list
    
    var searchType: ExploreType = .bars
    
    var selectedPreferences: [Category] = []
    
    var selectedStandardOffers: [StandardOffer] = []

    var shouldHidePreferenceButton: Bool = false
    
    let locationManager = MyLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        
        self.setUpStatefulTableView()
        
        self.mapView.delegate = self
        
        self.setUserLocation()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.setUpPreferencesButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //MARK: My Methods
    
    func resetCurrentData() {
        self.bars.removeAll()
        self.statefulTableView.reloadData()
    }
    
    func reset() {
        self.dataRequest?.cancel()
        self.resetCurrentData()
        
        self.statefulTableView.triggerInitialLoad()
    }
    
    func setUpMarkers() {
        
        self.mapView.clear()
        var bounds = GMSCoordinateBounds()
        for bar in self.bars {
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(bar.latitude.value), longitude: CLLocationDegrees(bar.longitude.value))
            
            bounds = bounds.includingCoordinate(location.coordinate)
            let marker = GMSMarker(position: location.coordinate)
            marker.userData = bar
            marker.map = self.mapView
        }
        
    }
    
    func setUpStatefulTableView() {
        
        self.statefulTableView.backgroundColor = .clear
        for aView in self.statefulTableView.subviews {
            aView.backgroundColor = .clear
        }
        
        self.statefulTableView.canLoadMore = false
        self.statefulTableView.canPullToRefresh = false
        self.statefulTableView.innerTable.rowHeight = UITableViewAutomaticDimension
        self.statefulTableView.innerTable.estimatedRowHeight = 250.0
        self.statefulTableView.innerTable.tableFooterView = UIView()
        self.statefulTableView.innerTable.separatorStyle = .none
        
        self.statefulTableView.innerTable.register(cellType: BarTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
        
        for aView in self.statefulTableView.innerTable.subviews {
            if aView.isMember(of: UIRefreshControl.self) {
                aView.removeFromSuperview()
                break
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
    
    func setupMapCamera(cordinate: CLLocationCoordinate2D) {
        let position = GMSCameraPosition.camera(withTarget: cordinate, zoom: 15.0)
        self.mapView.animate(to: position)
        self.mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
        self.mapView.settings.myLocationButton = true
        self.mapView.isMyLocationEnabled = true
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
        self.locationManager.requestLocation(desiredAccuracy: kCLLocationAccuracyHundredMeters, timeOut: 20.0) { [unowned self] (location, error) in
            
            guard error == nil else {
                debugPrint("Error while getting location: \(error!.localizedDescription)")
                self.setupMapCamera(cordinate: defaultUKLocation)
                return
            }
            
            if let location = location {
                self.setupMapCamera(cordinate: location.coordinate)
            }
        }
    }
    
    func moveToBarDetail(bar: Bar) {
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
        barDetailController.selectedBar = bar
        barDetailController.delegate = self
        
        switch self.searchType {
        case .liveOffers:
            barDetailController.preSelectedTabIndex = 2
        case .deals:
            barDetailController.preSelectedTabIndex = 1
        default:
            barDetailController.preSelectedTabIndex = 0
        }
        
        self.present(barDetailNav, animated: true, completion: nil)
    }
    
    func showDirection(bar: Bar) {
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let urlString = String(format: "comgooglemaps://?daddr=%f,%f&directionsmode=driving",bar.latitude.value,bar.longitude.value)
            let url = URL(string: urlString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            let url = URL(string: "https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    //MARK: My IBActions
    
    @IBAction func cancelBarButtonTapped(sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func listButtonTapped(sender: UIButton) {
        self.resetMapListSegment()
        
        sender.backgroundColor = UIColor.black
        sender.tintColor = UIColor.appBlueColor()
        
        self.displayType = .list
        
        self.scrollView.scrollToPage(page: 0, animated: true)
    }
    
    @IBAction func mapButtonTapped(sender: UIButton) {
        self.resetMapListSegment()
        
        sender.backgroundColor = UIColor.black
        sender.tintColor = UIColor.appBlueColor()
        
        self.displayType = .map
        
        self.scrollView.scrollToPage(page: 1, animated: true)
    }
    
    @IBAction func preferencesButtonTapped(sender: UIButton) {
        let categoriesController = self.storyboard?.instantiateViewController(withIdentifier: "CategoryFilterViewController") as! CategoryFilterViewController
        categoriesController.preSelectedCategories = self.selectedPreferences
        categoriesController.delegate = self
        self.navigationController?.pushViewController(categoriesController, animated: true)
    }
    
    @IBAction func standardOfferButtonTapped(sender: UIButton) {
        let standardOfferController = self.storyboard!.instantiateViewController(withIdentifier: "StandardOffersViewController") as! StandardOffersViewController
        standardOfferController.delegate = self
        self.navigationController?.pushViewController(standardOfferController, animated: true)
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

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
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        self.moveToBarDetail(bar: self.bars[indexPath.row])
    }
}

//MARK: UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        self.statefulTableView.triggerInitialLoad()
    }
}

//MARK: BarDetailViewControllerDelegate
extension SearchViewController: BarDetailViewControllerDelegate {
    func barDetailViewController(controller: BarDetailViewController, cancelButtonTapped sender: UIBarButtonItem) {
    }
}

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

//MARK: CategoriesViewControllerDelegate
extension SearchViewController: CategoryFilterViewControllerDelegate {
    func categoryFilterViewController(controller: CategoryFilterViewController, didSelectPrefernces selectedPreferences: [Category]) {
        self.selectedPreferences = selectedPreferences
        self.reset()
    }
}

//MARK: StandardOffersViewControllerDelegate
extension SearchViewController: StandardOffersViewControllerDelegate {
    func standardOffersViewController(controller: StandardOffersViewController, didSelectStandardOffers selectedOffers: [StandardOffer]) {
        self.selectedStandardOffers = selectedOffers
        self.reset()
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
