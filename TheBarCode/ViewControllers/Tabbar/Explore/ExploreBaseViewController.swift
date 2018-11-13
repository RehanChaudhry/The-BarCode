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

class ExploreBaseViewController: UIViewController {

    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet var snackBarContainer: UIView!
    
    @IBOutlet var listContainer: UIView!
    @IBOutlet var mapContainer: UIView!
    
    @IBOutlet var searchBarContainer: UIView!
    
    @IBOutlet var tempView: UIView!
    
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
        
        self.setUpStatefulTableView()
        self.mapView.delegate = self
        
        self.setUserLocation()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func createMapMarker(location: CLLocation) -> GMSMarker {
        let marker = GMSMarker(position: location.coordinate)
      //  let iconImage =  UIImage(named: "Pins")
      //  let markerView = UIImageView(image: iconImage)
      //  marker.iconView = markerView
        return marker
    }
    
    func setUpBarMarkers(bars: [Bar]) {
    
        mapView.clear()
        var bounds = GMSCoordinateBounds()
        for explore in bars {
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(explore.latitude.value), longitude: CLLocationDegrees(explore.longitude.value))
            
            bounds = bounds.includingCoordinate(location.coordinate)
            let marker = self.createMapMarker(location: location)
            marker.userData = explore
            marker.map = mapView
        }
        
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

    func showDirection(bar: Bar) {
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let urlString = String(format: "comgooglemaps://?saddr=,&daddr=%f,%f&directionsmode=driving",bar.latitude.value,bar.longitude.value)
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

extension ExploreBaseViewController : GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return false
    }
}


