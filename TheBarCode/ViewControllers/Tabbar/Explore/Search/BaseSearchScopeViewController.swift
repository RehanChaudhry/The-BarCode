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

protocol BaseSearchScopeViewControllerDelegate: class {
    func baseSearchScopeViewController(controller: BaseSearchScopeViewController, moveToBarDetails barId: String, scopeType: SearchScope)
    func baseSearchScopeViewController(controller: BaseSearchScopeViewController, refreshSnackBar refresh: Bool)
}

class BaseSearchScopeViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var listContainer: UIView!
    @IBOutlet var mapContainer: UIView!
    
    @IBOutlet var statefulTableView: StatefulTableView!
    @IBOutlet var mapView: GMSMapView!
    
    var dataRequest: DataRequest?
    
    var displayType: DisplayType = .list
    
    var selectedPreferences: [Category] = []
    
    var selectedStandardOffers: [StandardOffer] = []
    
    var markers: [GMSMarker] = []
    
    var keyword: String = ""
    
    let locationManager = MyLocationManager()
    
    var shouldReset: Bool = false
    
    var loadMore = Pagination()
    
    weak var baseDelegate: BaseSearchScopeViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUserLocation()
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
    
    func moveToBarDetails(barId: String, scopeType: SearchScope) {
        debugPrint("bar did select with id: \(barId)")
        self.baseDelegate.baseSearchScopeViewController(controller: self, moveToBarDetails: barId, scopeType: scopeType)
    }
    
    func refreshSnackBar() {
        self.baseDelegate.baseSearchScopeViewController(controller: self, refreshSnackBar: true)
    }
}
