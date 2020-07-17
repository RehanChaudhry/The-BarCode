//
//  MyCartViewController.swift
//  TheBarCode
//
//  Created by Macbook on 16/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView

class MyCartViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpStatefulTableView()
    }
    
    func setUpStatefulTableView() {
         
         self.statefulTableView.innerTable.register(cellType: OrderTableViewCell.self)
//         self.statefulTableView.innerTable.delegate = self
//         self.statefulTableView.innerTable.dataSource = self
         
         self.statefulTableView.backgroundColor = .clear
         for aView in self.statefulTableView.subviews {
             aView.backgroundColor = .clear
         }
         
         self.statefulTableView.canLoadMore = false
         self.statefulTableView.canPullToRefresh = false
         self.statefulTableView.innerTable.rowHeight = UITableViewAutomaticDimension
         self.statefulTableView.innerTable.estimatedRowHeight = 200.0
         self.statefulTableView.innerTable.tableFooterView = UIView()
         self.statefulTableView.innerTable.separatorStyle = .none

     }
}
