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
    
    var orders: [Order] = Order.getMyCartDummyOrders()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpStatefulTableView()
    }
    
    //MARK: My Methods
    func setUpStatefulTableView() {
         
         self.statefulTableView.innerTable.register(cellType: OrderItemTableViewCell.self)
        self.statefulTableView.innerTable.register(headerFooterViewType: CartSectionHeaderView.self)

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
    
    func calculateBill(order: Order) {
          
         // let productInfoSection = self.viewModels.compactMap({$0 as? StoreOrderProductsInfoSection}).first!
          
          var total: Double = 0.0
          
          for orderItem in order.orderItems {
              total += ( orderItem.unitPrice * Double(orderItem.quantity))
          }
                                    
          
          self.statefulTableView.innerTable.reloadData()
      }
}


//MARK: UITableViewDataSource, UITableViewDelegate

extension MyCartViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 54.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.orders.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders[section].orderItems.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(CartSectionHeaderView.self)
        headerView?.setupHeader(title: self.orders[section].barName)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: OrderItemTableViewCell.self)
        cell.orderItem = self.orders[indexPath.section].orderItems[indexPath.item]
        cell.setUpCell(orderItem: self.orders[indexPath.section].orderItems[indexPath.item])
        cell.delegate = self
        return cell
    }
         
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
    }
}

//MARK: OrderItemTableViewCellDelegate
extension MyCartViewController: OrderItemTableViewCellDelegate {
    func orderItemTableViewCell(cell: OrderItemTableViewCell, deleteButtonTapped sender: UIButton) {
        
    }
    
    func orderItemTableViewCell(cell: OrderItemTableViewCell, stepperValueChanged stepper: StepperView) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("IndexPath not found")
            return
        }
               
        guard let order = self.orders[indexPath.section] as? Order else {
            debugPrint("Not a order info section")
            return
        }
        
        self.calculateBill(order: order)

    }
}
