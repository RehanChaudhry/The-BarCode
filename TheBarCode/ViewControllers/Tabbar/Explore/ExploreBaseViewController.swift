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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    }

}
