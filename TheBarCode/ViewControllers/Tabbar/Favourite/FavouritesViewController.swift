//
//  FavouritesViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView

class FavouritesViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    var bars: [Bar] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 21))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.appBoldFontOf(size: 16.0)
        titleLabel.textColor = UIColor.white
        titleLabel.text = "Favourites"
        self.navigationItem.titleView = titleLabel
        
        self.setUpStatefulTableView()
        
       // self.bars = Bar.getDummyFavList()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpStatefulTableView() {
        
        self.statefulTableView.innerTable.register(cellType: BarTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        
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
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension FavouritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: BarTableViewCell.self)
        cell.setUpCell(bar: self.bars[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        let exploreDetailNav = (self.storyboard?.instantiateViewController(withIdentifier: "ExploreDetailNavigation") as! UINavigationController)
        self.present(exploreDetailNav, animated: true, completion: nil)
    }
}


