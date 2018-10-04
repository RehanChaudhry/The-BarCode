//
//  ExploreLiveOffersViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import SJSegmentedScrollView

protocol ExploreDetailLiveOffersViewControllerDelegate: class {
    func exploreOffersController(controller: ExploreDetailLiveOffersViewController, didSelectRowAt indexPath: IndexPath)
}

class ExploreDetailLiveOffersViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    var offers: [LiveOffer] = []
    
    weak var delegate: ExploreDetailLiveOffersViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.offers = LiveOffer.getDummyList()
     
        
        self.setUpStatefulTableView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My Methods
    
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
        
        self.statefulTableView.innerTable.register(cellType: LiveOfferTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension ExploreDetailLiveOffersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: LiveOfferTableViewCell.self)
        cell.setUpCell(offer: self.offers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        self.delegate.exploreOffersController(controller: self, didSelectRowAt: indexPath)
    }
}

//MARK: SJSegmentedViewControllerViewSource
extension ExploreDetailLiveOffersViewController: SJSegmentedViewControllerViewSource {
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return self.statefulTableView.innerTable
    }
}
