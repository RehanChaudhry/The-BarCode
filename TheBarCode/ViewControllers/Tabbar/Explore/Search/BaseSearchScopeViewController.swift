//
//  BaseSearchScopeViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 19/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import GoogleMaps
import Alamofire
import CoreLocation
import CoreStore
import PureLayout

protocol BaseSearchScopeViewControllerDelegate: class {
    func baseSearchScopeViewController(controller: BaseSearchScopeViewController, scrollViewDidScroll scrollView: UIScrollView)
    func baseSearchScopeViewController(controller: BaseSearchScopeViewController, moveToBarDetails barId: String, scopeType: SearchScope, dealsSubType: BarDetailDealsPreSelectedSubTabType)
    func baseSearchScopeViewController(controller: BaseSearchScopeViewController, refreshSnackBar refresh: Bool)
}

enum BarDetailDealsPreSelectedSubTabType: String {
    case none = "none", chalkboard = "chalkboard", exclusive = "exclusive"
}

class BaseSearchScopeViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var listContainer: UIView!
    @IBOutlet var mapContainer: UIView!
    
    @IBOutlet var statefulTableView: StatefulTableView!
    
    @IBOutlet var mapErrorView: ShadowView!
    
    @IBOutlet var mapLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var mapReloadButton: UIButton!
    
    var myLocationButtonContainer: ShadowView!
    var myLocationButton: UIButton!
    
    var mapView: GMSMapView?
    
    var dataRequest: DataRequest?
    
    var displayType: DisplayType = .list
    
    var selectedPreferences: [Category] = []
    
    var selectedStandardOffers: [StandardOffer] = []
    var selectedRedeemingType: RedeemingTypeModel?
    var selectedDeliveryFilter: DeliveryFilter?
    
    var keyword: String = ""
    
    let locationManager = MyLocationManager()
    
    var shouldReset: Bool = false
    
    var loadMore = Pagination()
    
    weak var baseDelegate: BaseSearchScopeViewControllerDelegate!
    
    var strokeView: UIView!
    
    var clusterManager: GMUClusterManager?
    
    var mapApiState: LoadMore = LoadMore(isLoading: false, canLoadMore: false, error: nil)
    var mapDataRequest: DataRequest?
    var mapBars: [MapBasicBar] = []
    
    var mapCameraPosition: GMSCameraPosition?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        self.setUserLocation()
        self.setupMyLocationButton()
        
        self.strokeView = UIView()
        if self is BarSearchViewController {
            self.strokeView.backgroundColor = UIColor.appSearchScopeBarsColor()
        } else if self is DealSearchViewController {
            self.strokeView.backgroundColor = UIColor.appSearchScopeDealsColor()
        } else if self is LiveOfferSearchViewController {
            self.strokeView.backgroundColor = UIColor.appSearchScopeLiveOffersColor()
        } else if self is FoodSearchViewController {
            self.strokeView.backgroundColor = UIColor.appSearchScopeFoodsColor()
        } else if self is DrinkSearchViewController {
            self.strokeView.backgroundColor = UIColor.appSearchScopeDrinksColor()
        } else if self is EventSearchViewController {
            self.strokeView.backgroundColor = UIColor.appSearchScopeEventsColor()
        } else {
            self.strokeView.backgroundColor = UIColor.clear
        }
        
        self.view.addSubview(self.strokeView)
        
        self.strokeView.autoPinEdge(ALEdge.top, to: ALEdge.top, of: self.view)
        self.strokeView.autoPinEdge(ALEdge.left, to: ALEdge.left, of: self.view)
        self.strokeView.autoPinEdge(ALEdge.right, to: ALEdge.right, of: self.view)
        self.strokeView.autoSetDimension(ALDimension.height, toSize: 8.0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(barDetailsRefreshedNotification(notification:)), name: notificationNameBarDetailsRefreshed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        
        self.scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize), options: [NSKeyValueObservingOptions.new], context: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupMapView()
        if !self.mapApiState.isLoading {
            self.setUpMapViewForLocations()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.clearMapView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.restoreMapCameraPosition(animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameBarDetailsRefreshed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        self.scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentSize))
        
        debugPrint("Deinit called: \(String(describing: self))")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if let scrollView = object as? UIScrollView, scrollView == self.scrollView,  let keyPath = keyPath, keyPath == #keyPath(UIScrollView.contentSize) {
            
            debugPrint("Content size did updated: \(scrollView.contentSize)")
            
            //As we are using pageviewcontroller, the view of selected scope item may not be added on the parent controller view which results in scrollview content size zero
            if self.displayType == DisplayType.map {
                self.showMapView(animted: false)
            } else {
                self.showListView(animted: false)
            }
        }
    }
    
    //MARK: My Methods
    
    func setupMyLocationButton() {
        
        self.myLocationButtonContainer = ShadowView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        self.myLocationButtonContainer.backgroundColor = self.mapErrorView.backgroundColor
        self.myLocationButtonContainer.cornerRadius = 22.0
        self.myLocationButtonContainer.shadowColor = self.mapErrorView.shadowColor
        self.myLocationButtonContainer.shadowRadius = self.mapErrorView.shadowRadius
        self.myLocationButtonContainer.shadowOffset = self.mapErrorView.shadowOffset
        self.myLocationButtonContainer.shadowOpacity = self.mapErrorView.shadowOpacity
        
        self.myLocationButton = UIButton(type: .system)
        self.myLocationButton.setImage(UIImage(named: "icon_my_location"), for: .normal)
        self.myLocationButton.addTarget(self, action: #selector(myLocationButtonTapped(sender:)), for: .touchUpInside)
        self.myLocationButton.tintColor = UIColor.white
        self.myLocationButtonContainer.addSubview(self.myLocationButton)
        self.myLocationButton.autoPinEdgesToSuperviewEdges()
        
        self.mapContainer.addSubview(self.myLocationButtonContainer)
        self.myLocationButtonContainer.autoSetDimensions(to: self.myLocationButtonContainer.frame.size)
        self.myLocationButtonContainer.autoPinEdge(ALEdge.right, to: ALEdge.right, of: self.mapContainer, withOffset: -16.0)
        self.myLocationButtonContainer.autoPinEdge(ALEdge.bottom, to: ALEdge.top, of: self.mapErrorView, withOffset: -16.0)
        
        self.myLocationButtonContainer.isHidden = CLLocationManager.authorizationStatus() == .notDetermined
    }
    
    func prepareToReset() {
        self.shouldReset = true
    }
    
    func reset() {
        
    }
    
    func resetCurrentData() {
        
    }
    
    func showListView(animted: Bool) {
        self.displayType = .list
        self.scrollView.scrollToPage(page: 0, animated: animted)
    }
    
    func showMapView(animted: Bool) {
        self.displayType = .map
        self.scrollView.scrollToPage(page: 1, animated: animted)
        
        if !self.mapApiState.isLoading {
            self.setUpMapViewForLocations()
        }
    }
    
    func setUpStatefulTableView() {
        
        self.statefulTableView.backgroundColor = .clear
        for aView in self.statefulTableView.subviews {
            aView.backgroundColor = .clear
        }
        
        self.statefulTableView.canLoadMore = false
        self.statefulTableView.canPullToRefresh = true
        self.statefulTableView.innerTable.rowHeight = UITableViewAutomaticDimension
        self.statefulTableView.innerTable.estimatedRowHeight = 250.0
        self.statefulTableView.innerTable.tableFooterView = UIView()
        self.statefulTableView.innerTable.separatorStyle = .none
    }
    
    func setupMapView() {
        
        let mapView = GMSMapView(frame: CGRect.zero)
        mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
        if CLLocationManager.authorizationStatus() != .notDetermined {
            mapView.settings.myLocationButton = false
            mapView.isMyLocationEnabled = true
            
            self.myLocationButtonContainer.isHidden = false
        } else {
            self.myLocationButtonContainer.isHidden = true
        }
        
        self.mapContainer.insertSubview(mapView, at: 0)
        
        mapView.autoPinEdgesToSuperviewEdges()
        
        let iconGenerator = GMUCustomClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        
        self.clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        self.clusterManager?.setDelegate(self, mapDelegate: self)
        
        self.mapView = mapView
        
        self.setUpMarkers()
        
        self.restoreMapCameraPosition(animated: false)
    }
    
    func clearMapView() {
        
        self.clusterManager?.clearItems()
        
        self.mapView?.clear()
        self.mapView?.removeFromSuperview()
        
        self.mapView = nil
        self.clusterManager = nil
    }
    
    func setupMapCamera(cordinate: CLLocationCoordinate2D) {
        let position = GMSCameraPosition.camera(withTarget: cordinate, zoom: 15.0)
        self.mapView?.animate(to: position)
        
        self.mapCameraPosition = position
    }
    
    func restoreMapCameraPosition(animated: Bool) {
        if let camera = self.mapCameraPosition {
            if animated {
                self.mapView?.animate(to: camera)
            } else {
                self.mapView?.camera = camera
            }
        } else {
            debugPrint("Camera position not available for restoration")
        }
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

    func showDirection(bar: Bar) {
        let mapUrl = "https://www.google.com/maps/dir/?api=1&destination=\(bar.latitude.value)+\(bar.longitude.value)"
        UIApplication.shared.open(URL(string: mapUrl)!, options: [:]) { (success) in
            
        }
    }
    
    func moveToBarDetails(barId: String, scopeType: SearchScope, dealDetailSubType: BarDetailDealsPreSelectedSubTabType = .none) {
        debugPrint("bar did select with id: \(barId)")
        self.baseDelegate.baseSearchScopeViewController(controller: self, moveToBarDetails: barId, scopeType: scopeType, dealsSubType: dealDetailSubType)
    }
    
    func refreshSnackBar() {
        self.baseDelegate.baseSearchScopeViewController(controller: self, refreshSnackBar: true)
    }
    
    func setUpMapViewForLocations() {
        
    }
    
    func setUpMarkers() {
        
        self.mapView?.clear()
        self.clusterManager?.clearItems()
        
        self.mapBars.removeAll(where: {$0.position.latitude > 85.0})        
        self.mapBars.removeAll(where: {$0.position.latitude < -85.0})
        
        for mapBar in self.mapBars {
            self.clusterManager?.add(mapBar)
        }
        
        self.clusterManager?.cluster()
        
    }
    
    func scrollDidScroll(scrollView: UIScrollView) {
        self.baseDelegate.baseSearchScopeViewController(controller: self, scrollViewDidScroll: scrollView)
    }
    
    func getCurrentSearchScope() -> SearchScope {
        
        var searchScope = SearchScope.all
        
        if self is BarSearchViewController {
            searchScope = .bar
        } else if self is DealSearchViewController {
            searchScope = .deal
        } else if self is LiveOfferSearchViewController {
            searchScope = .liveOffer
        } else if self is FoodSearchViewController {
            searchScope = .food
        } else if self is DrinkSearchViewController {
            searchScope = .drink
        } else if self is EventSearchViewController {
            searchScope = .event
        }
        
        return searchScope
    }
    
    @objc func myLocationButtonTapped(sender: UIButton) {
        if let location = self.mapView?.myLocation {
            let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15.0)
            self.mapView?.animate(to: position)
        }
    }
    
    //MARK: My IBActions
    @IBAction func mapRetryButtonTapped(sender: UIButton) {
        self.setUpMapViewForLocations()
    }

}

//MARK: GMUClusterManagerDelegate
extension BaseSearchScopeViewController: GMUClusterManagerDelegate {
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        
        var latlngBounds = GMSCoordinateBounds(coordinate: cluster.items.first!.position,
                                               coordinate: cluster.items.first!.position)
        for clusterItem in cluster.items {
            latlngBounds = latlngBounds.includingCoordinate(clusterItem.position)
        }
        
        let update = GMSCameraUpdate.fit(latlngBounds, withPadding: 150.0)
        self.mapView?.animate(with: update)
        
        return true
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        return false
    }
}

//MARK: GMUClusterRendererDelegate
extension BaseSearchScopeViewController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let mapBar = marker.userData as? MapBasicBar {
            marker.icon = Utility.shared.getMapBarPinImage(mapBar: mapBar)
            marker.zIndex = Int32(self.mapBars.firstIndex(of: mapBar) ?? 0)
        }
    }
}

//MARK: GMSMapViewDelegate
extension BaseSearchScopeViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let mapbar = marker.userData as? MapBasicBar {
            
            let selectedBarLocation = CLLocation(latitude: mapbar.latitude, longitude: mapbar.longitude)
            
            let filteredBars = self.mapBars.filter { (bar) -> Bool in
                let location = CLLocation(latitude: bar.latitude, longitude: bar.longitude)
                return location.distance(from: selectedBarLocation) < 10.0
            }
            
            if filteredBars.count > 1 {
                
                let mapPinsController = self.storyboard!.instantiateViewController(withIdentifier: "MapPinsViewController") as! MapPinsViewController
                mapPinsController.mapBars = filteredBars
                mapPinsController.delegate = self
                mapPinsController.modalPresentationStyle = .overCurrentContext
                mapPinsController.modalTransitionStyle = .crossDissolve
                self.present(mapPinsController, animated: true, completion: nil)
                
                //Needs little offset to be perfectly in center b/c of other views
                let adjustedCenterPoint = mapPinsController.view.convert(self.mapContainer.center, from: self.mapContainer)
                mapPinsController.centerYConstraint.constant = adjustedCenterPoint.y - mapPinsController.view.center.y
                
//                debugPrint("Multiple establishments detected: \(filteredBars.map({$0.title}))")
//                debugPrint("Selected establishment title: \(mapbar.title)")
            } else {
                let searchScope = self.getCurrentSearchScope()
                self.moveToBarDetails(barId: mapbar.barId, scopeType: searchScope)
            }
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.mapCameraPosition = position
    }
}

//MARK: MapPinsViewController
extension BaseSearchScopeViewController: MapPinsViewControllerDelegate {
    func mapPinsViewController(controller: MapPinsViewController, didSelectMapBar mapBar: MapBasicBar) {
        controller.dismiss(animated: true) {
            let searchScope = self.getCurrentSearchScope()
            self.moveToBarDetails(barId: mapBar.barId, scopeType: searchScope)
        }
    }
}

//Notification Methods
extension BaseSearchScopeViewController {
    @objc func barDetailsRefreshedNotification(notification: Notification) {
        
        let bar = notification.object as! Bar
        
        if let mapBar = self.mapBars.first(where: {$0.barId == bar.id.value}) {
            var isOpened = false
            if let timings = bar.timings.value {
                if timings.dayStatus == .opened {
                    if timings.isOpen.value {
                        isOpened  = true
                        
                    }
                }
                
            }
            mapBar.isOpen = isOpened
            
            self.clusterManager?.remove(mapBar)
            
            self.clusterManager?.add(mapBar)
            self.clusterManager?.cluster()
        }
    }
    
    @objc func applicationDidBecomeActive(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.mapApiState.isLoading {
                self.setUpMapViewForLocations()
            }
        }
    }
}
