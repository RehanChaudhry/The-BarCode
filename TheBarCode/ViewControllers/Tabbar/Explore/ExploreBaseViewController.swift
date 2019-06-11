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
    @IBOutlet var mapView: GMSMapView!
    
    var displayType: DisplayType = .list
    
    var snackBar: SnackbarView = SnackbarView.loadFromNib()
    
    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    var bars: [Bar] = []  //bars
    var filteredBars: [Bar] = [] //searched bars
    var isSearching = false
    var searchText = ""
    
    var canReload: Bool = true
    var redeemInfo: RedeemInfo!

    let locationManager = MyLocationManager()
    
    var markers: [GMSMarker] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
        self.mapView.delegate = self
        
        self.setUserLocation()
        
        NotificationCenter.default.addObserver(self, selector: #selector(barDetailsRefreshedNotification(notification:)), name: notificationNameBarDetailsRefreshed, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameBarDetailsRefreshed, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.statefulTableView.innerTable.reloadData()
    }
    
    //MARK: My Methods
    
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
    
    func createMapMarker(location: CLLocation, pinImage: UIImage) -> GMSMarker {
        let marker = GMSMarker(position: location.coordinate)
        let iconImage = pinImage
        let markerView = UIImageView(image: iconImage)
        marker.iconView = markerView
        return marker
    }
    
    func setUpBarMarkers(bars: [Bar]) {
    
        self.mapView.clear()
        self.markers.removeAll()
        
        var bounds = GMSCoordinateBounds()
        for (index, explore) in bars.enumerated() {
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(explore.latitude.value), longitude: CLLocationDegrees(explore.longitude.value))
            
            bounds = bounds.includingCoordinate(location.coordinate)
            
            let pinImage = self.getPinImage(explore: explore)
            let marker = self.createMapMarker(location: location, pinImage: pinImage)
            marker.userData = explore
            marker.zIndex = Int32(index)
            marker.map = mapView
            
            self.markers.append(marker)
        }
        
    }
    
    func getPinImage(explore: Bar) -> UIImage {
        var pinImage = UIImage(named: "icon_pin_gold")!
        if let timings = explore.timings.value {
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
        
        return pinImage
    }
    
    func setupMapCamera(cordinate: CLLocationCoordinate2D) {
        let position = GMSCameraPosition.camera(withTarget: cordinate, zoom: 15.0)
        self.mapView.animate(to: position)
        self.mapView.settings.allowScrollGesturesDuringRotateOrZoom = false
        self.mapView.settings.myLocationButton = true
        self.mapView.isMyLocationEnabled = true
    }
    
    func refreshMap() {
        let bars = self.isSearching ? self.filteredBars : self.bars
        self.setUpBarMarkers(bars: bars)
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
                        edittedUser?.latitude.value = location!.coordinate.latitude
                        edittedUser?.longitude.value = location!.coordinate.longitude
                        
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
        
        self.refreshMap()
    }
}

//MARK: GMSMapViewDelegate
extension ExploreBaseViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
}

//Notification Methods
extension ExploreBaseViewController {
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
        marker.map = mapView
        
        self.markers.append(marker)
        
        marker.zIndex = Int32(self.markers.count - 1)
        
    }
}

