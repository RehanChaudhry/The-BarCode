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
    @IBOutlet var mapView: GMSMapView!
    
    @IBOutlet var mapErrorView: ShadowView!
    
    var dataRequest: DataRequest?
    
    var displayType: DisplayType = .list
    
    var selectedPreferences: [Category] = []
    
    var selectedStandardOffers: [StandardOffer] = []
    
    var keyword: String = ""
    
    let locationManager = MyLocationManager()
    
    var shouldReset: Bool = false
    
    var loadMore = Pagination()
    
    weak var baseDelegate: BaseSearchScopeViewControllerDelegate!
    
    var strokeView: UIView!
    
    var clusterManager: GMUClusterManager!
    
    var mapApiState: LoadMore = LoadMore(isLoading: false, canLoadMore: false, error: nil)
    var mapDataRequest: DataRequest?
    var mapBars: [MapBasicBar] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        let iconGenerator = GMUDefaultClusterIconGenerator()
        let iconGenerator = GMUCustomClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        
        self.clusterManager = GMUClusterManager(map: self.mapView, algorithm: algorithm, renderer: renderer)
        self.clusterManager.setDelegate(self, mapDelegate: self)
        
        self.setUserLocation()
        
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
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameBarDetailsRefreshed, object: nil)
    }
    

    //MARK: My Methods
    func prepareToReset() {
        self.shouldReset = true
    }
    
    func reset() {
        
    }
    
    func resetCurrentData() {
        
    }
    
    func showListView() {
        self.displayType = .list
        self.scrollView.scrollToPage(page: 0, animated: true)
    }
    
    func showMapView() {
        self.displayType = .map
        self.scrollView.scrollToPage(page: 1, animated: true)
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
    
    func setupMapCamera(cordinate: CLLocationCoordinate2D) {
        let position = GMSCameraPosition.camera(withTarget: cordinate, zoom: 15.0)
        self.mapView.animate(to: position)
        self.mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
        
        if CLLocationManager.authorizationStatus() != .notDetermined {
            self.mapView.settings.myLocationButton = true
            self.mapView.isMyLocationEnabled = true
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
        
        self.mapView.clear()
        self.clusterManager.clearItems()
        
        self.mapBars.removeAll(where: {$0.position.latitude > 85.0})        
        self.mapBars.removeAll(where: {$0.position.latitude < -85.0})
        
        for mapBar in self.mapBars {
            self.clusterManager.add(mapBar)
        }
        
        self.clusterManager.cluster()
        
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
        self.mapView.animate(with: update)
        
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
        }
    }
}

//MARK: GMSMapViewDelegate
extension BaseSearchScopeViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let mapbar = marker.userData as? MapBasicBar {
            let searchScope = self.getCurrentSearchScope()
            self.moveToBarDetails(barId: mapbar.barId, scopeType: searchScope)
        }
        return false
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
            
            self.clusterManager.remove(mapBar)
            
            self.clusterManager.add(mapBar)
            self.clusterManager.cluster()
        }
    }
}
