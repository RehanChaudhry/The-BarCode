//
//  LiveOffersViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit

protocol LiveOffersViewControllerDelegate: class {
    func liveOffersController(controller: LiveOffersViewController, didSelectLiveOffer offer: Any)
}

class LiveOffersViewController: ExploreBaseViewController {

    var offers: [LiveOffer] = []
    
    weak var delegate: LiveOffersViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.searchBar.delegate = self
        
        self.snackBar.updateAppearanceForType(type: .reload, gradientType: .green)
        
        self.offers = LiveOffer.getDummyList()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: My Methods
    
    override func setUpStatefulTableView() {
        super.setUpStatefulTableView()
        
        self.statefulTableView.innerTable.register(cellType: LiveOfferTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
    }

}

//MARK: UITableViewDataSource, UITableViewDelegate

extension LiveOffersViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
        self.delegate.liveOffersController(controller: self, didSelectLiveOffer: self.offers[indexPath.row])
    }
}

//MARK: UISearchBarDelegate

extension LiveOffersViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

