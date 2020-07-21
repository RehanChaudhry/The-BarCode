//
//  MyOrdersController.swift
//  TheBarCode
//
//  Created by Macbook on 16/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import CoreStore
import ObjectMapper
import Alamofire
import FirebaseAnalytics

class MyOrdersViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
  
    var segments: [OrderCategory] = OrderCategory.getAllDummyOrders()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpStatefulTableView()
    }
    
    //MARK: My Methods
   func setUpStatefulTableView() {
        
        self.statefulTableView.innerTable.register(cellType: OrderTableViewCell.self)
        self.statefulTableView.innerTable.register(headerFooterViewType: SectionHeaderView.self)

        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        
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
    
    func moveToOrderDetailsVC(order: Order) {
        
        let orderDetailsNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "OrderDetailsNavigation") as! UINavigationController)
        orderDetailsNavigation.modalPresentationStyle = .fullScreen
               
        let orderDetailsViewController = orderDetailsNavigation.viewControllers.first as! OrderDetailsViewController
        orderDetailsViewController.order = order
        
        self.present(orderDetailsNavigation, animated: true, completion: nil)
    }

}


//MARK: UITableViewDataSource, UITableViewDelegate

extension MyOrdersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.segments.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.segments[section].orders.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(SectionHeaderView.self)
        headerView?.setupHeader(title: self.segments[section].getTitle())
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: OrderTableViewCell.self)
        cell.setUpCell(order: self.segments[indexPath.section].orders[indexPath.item])
        return cell
    }
         
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        let order =  self.segments[indexPath.section].orders[indexPath.item]
        self.moveToOrderDetailsVC(order: order)
    }
}
