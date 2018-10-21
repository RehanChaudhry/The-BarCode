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
    
    var bars: [Bar] = []

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
        
        self.checkReloadStatus()
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
    
    func canTimerReload(redeemInfo: RedeemInfo) -> Bool {
        let interval =  TimeInterval(redeemInfo.remainingSeconds!)
        return (Utility.shared.checkTimerEnd(time:interval))
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
        
        self.setUpBarMarkers(bars: self.bars)
                
    }
}

//MARK: Web API
extension ExploreBaseViewController {
    func checkReloadStatus() {
        
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathReloadStatus, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("Error while getting reload status \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard serverError == nil else {
                if serverError!.statusCode == HTTPStatusCode.notFound.rawValue {
                    //Show alert when tap on reload
                    //All your deals are already unlocked no need to reload
                    self.canReload = false
                } else {
                    debugPrint("Error while getting reload status \(String(describing: serverError?.errorMessages()))")
                }
                
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseReloadStatusDict = (responseDict?["data"] as? [String : Any]) {
                
                let redeemInfo = Mapper<RedeemInfo>().map(JSON: responseReloadStatusDict)!
                
                debugPrint("current servertimer \(redeemInfo .currentServerDatetime!)")
                debugPrint("redeem time \(redeemInfo .redeemDatetime!)!")
                
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("Error while getting reload status \(genericError.localizedDescription)")
            }
        }
    }
}


