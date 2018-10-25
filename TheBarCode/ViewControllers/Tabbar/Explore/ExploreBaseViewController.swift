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
    
    func createMapMarker(explore: Bar) -> GMSMarker {
        
        let location: CLLocation = CLLocation(latitude: CLLocationDegrees(explore.latitude.value), longitude: CLLocationDegrees(explore.longitude.value))
        
        let marker = GMSMarker(position: location.coordinate)
        marker.title = explore.title.value
        marker.snippet = explore.address.value

        return marker
    }
    
    func setUpBarMarkers(bars: [Bar]) {
    
        mapView.clear()
        mapView.isMyLocationEnabled = true
        
        var bounds = GMSCoordinateBounds()
        for explore in bars {
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(explore.latitude.value), longitude: CLLocationDegrees(explore.longitude.value))
            
            bounds = bounds.includingCoordinate(location.coordinate)
            let marker = self.createMapMarker(explore: explore)
            
            let iconImage =  UIImage(named: "Pins")
            let markerView = UIImageView(image: iconImage)
            marker.iconView = markerView

            marker.map = mapView
        }
        
        let update = GMSCameraUpdate.fit(bounds, withPadding: 60.0)
        mapView.animate(with: update)
        
    }
    
    /*
    func updateSnackBar() {
        
        if let redeemInfo = ReedeemInfoManager.shared.redeemInfo {
            
            if redeemInfo.isFirstRedeem && redeemInfo.remainingSeconds == 0 {
                // Discount
                self.snackBar.updateAppearanceForType(type: .discount, gradientType: .green)
            } else if !redeemInfo.isFirstRedeem && redeemInfo.remainingSeconds == 0 {
                //Congrates
                self.snackBar.updateAppearanceForType(type: .congrates, gradientType: .orange)
            } else if !redeemInfo.isFirstRedeem && redeemInfo.remainingSeconds > 0 {
                //reload in
                  self.snackBar.updateAppearanceForType(type: .reload, gradientType: .green)
            }
        } else {
            self.snackBar.loadingSpinner()
        }
        
//
//        if ReedeemInfoManager.shared.canReload {
//            if ReedeemInfoManager.shared.redeemInfo?.canShowTimer() ?? false {
//                self.snackBar.updateAppearanceForType(type: .reload, gradientType: .green)
//            } else {
//                self.snackBar.updateAppearanceForType(type: .congrates, gradientType: .orange)
//            }
//        } else {
//            self.snackBar.updateAppearanceForType(type: .discount, gradientType: .green)
//        }
    }
    
    func invalidateTimer(){
        self.snackBar.timer.invalidate()
    }
    */
  

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
        
        self.setUpBarMarkers(bars: self.bars)
                
    }
}


