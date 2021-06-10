//
//  ExploreBaseViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import GoogleMaps
import Alamofire
import ObjectMapper
import HTTPStatusCodes
import CoreLocation
import CoreStore
import PureLayout

class ExploreBaseViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var snackBarContainer: UIView!
    
    @IBOutlet var listContainer: UIView!
    @IBOutlet var mapContainer: UIView!
    
    @IBOutlet var searchBarContainer: UIView!
    
    @IBOutlet var tempView: UIView!
    
    @IBOutlet var standardOfferButton: UIButton!
    @IBOutlet var preferencesButton: UIButton!
    @IBOutlet var mapButton: UIButton!
    @IBOutlet var listButton: UIButton!
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var statefulTableView: StatefulTableView!
    var mapView: GMSMapView?
    
    @IBOutlet var mapErrorView: ShadowView!
    
    @IBOutlet var mapLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var mapReloadButton: UIButton!
    
    var myLocationButtonContainer: ShadowView!
    var myLocationButton: UIButton!
    
    var displayType: DisplayType = .list
    
    var snackBar = SnackBarInfoView.loadFromNib()
    
    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    var bars: [Bar] = []  //bars
    var filteredBars: [Bar] = [] //searched bars
    var isSearching = false
    var searchText = ""
    
    var canReload: Bool = true
    var redeemInfo: RedeemInfo!

    let locationManager = MyLocationManager()
    
    var clusterManager: GMUClusterManager?

    var mapApiState: LoadMore = LoadMore(isLoading: false, canLoadMore: false, error: nil)
    var mapDataRequest: DataRequest?
    var mapBars: [MapBasicBar] = []
    
    var mapCameraPosition: GMSCameraPosition?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.listButton.roundCorners(corners: [.topLeft, .bottomLeft], radius: 5.0)
        self.mapButton.roundCorners(corners: [.topRight, .bottomRight], radius: 5.0)
        
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.appGrayColor()
        
        self.snackBarContainer.addSubview(snackBar)
        self.snackBar.autoPinEdgesToSuperviewEdges()
        
        self.resetMapListSegment()
        self.listButton.backgroundColor = UIColor.black
        self.listButton.tintColor = UIColor.appBlueColor()
        
        self.standardOfferButton.backgroundColor = self.tempView.backgroundColor
        self.standardOfferButton.tintColor = UIColor.appGrayColor()
        
        self.preferencesButton.backgroundColor = self.tempView.backgroundColor
        self.preferencesButton.tintColor = UIColor.appGrayColor()
        
        self.setUpStatefulTableView()
        
        self.setUserLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(barDetailsRefreshedNotification(notification:)), name: notificationNameBarDetailsRefreshed, object: nil)
        
        self.setupMyLocationButton()

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive(notification:)), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameBarDetailsRefreshed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupMapView()
        self.statefulTableView.innerTable.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.clearMapView()
    }
    
    //MARK: My Methods
    
    func setUpBasicMapBars() {
        
    }
    
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
    
    @objc func myLocationButtonTapped(sender: UIButton) {
        if let location = self.mapView?.myLocation {
            let position = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: 15.0)
            self.mapView?.animate(to: position)
        }
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
    
    func resetMapListSegment() {
        self.mapButton.backgroundColor = self.tempView.backgroundColor
        self.listButton.backgroundColor = self.tempView.backgroundColor
        
        self.mapButton.tintColor = UIColor.appGrayColor()
        self.listButton.tintColor = UIColor.appGrayColor()
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

    func setUserLocation() {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        let canContinue = authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse
        
        guard canContinue else {
            debugPrint("Location permission not authorized")
            self.setupMapCamera(cordinate: defaultUKLocation)
            return
        }
        
        self.locationManager.locationPreferenceAlways = authorizationStatus == .authorizedAlways
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
    //MARK: My IBActions
    
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
        
        if !self.mapApiState.isLoading {
            self.setUpBasicMapBars()
        }
    }
}

//MARK: GMSMapViewDelegate
extension ExploreBaseViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        self.mapCameraPosition = position
    }
}


//Notification Methods
extension ExploreBaseViewController {
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
        
        
        /*
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
        marker.map = mapView
        
        self.markers.append(marker)
        
        marker.zIndex = Int32(self.markers.count - 1)
        */
    }
    
    @objc func applicationDidBecomeActive(notification: Notification) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !self.mapApiState.isLoading {
                self.setUpBasicMapBars()
            }
        }
    }
}

//MARK: GMUClusterManagerDelegate
extension ExploreBaseViewController: GMUClusterManagerDelegate {
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        
        var latlngBounds = GMSCoordinateBounds(coordinate: cluster.items.first!.position,
                                               coordinate: cluster.items.first!.position)
        for clusterItem in cluster.items {
            latlngBounds = latlngBounds.includingCoordinate(clusterItem.position)
        }
        
        let update = GMSCameraUpdate.fit(latlngBounds, withPadding: 150.0)
        self.mapView?.animate(with: update)
        
        return false
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        return false
    }
}

//MARK: GMUClusterRendererDelegate
extension ExploreBaseViewController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
        if let mapBar = marker.userData as? MapBasicBar {
            marker.icon = Utility.shared.getMapBarPinImage(mapBar: mapBar)
            marker.zIndex = Int32(self.mapBars.firstIndex(of: mapBar) ?? 0)
        }
    }
}
