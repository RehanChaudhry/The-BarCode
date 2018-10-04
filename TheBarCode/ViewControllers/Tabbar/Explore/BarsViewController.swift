//
//  BarsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

protocol BarsViewControllerDelegate: class {
    func barsController(controller: BarsViewController, didSelectBar bar: Any)
}

class BarsViewController: ExploreBaseViewController {
    
    weak var delegate: BarsViewControllerDelegate!
    
    var bars: [Bar] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.searchBar.delegate = self
        
        self.snackBar.updateAppearanceForType(type: .discount, gradientType: .green)
        
        self.bars = Bar.getDummyList()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: My Methods
    
    override func setUpStatefulTableView() {
        super.setUpStatefulTableView()
        
        self.statefulTableView.innerTable.register(cellType: BarTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension BarsViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
        self.delegate.barsController(controller: self, didSelectBar: indexPath)
    }
}

//MARK: UISearchBarDelegate

extension BarsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
