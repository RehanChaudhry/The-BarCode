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
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var barNameLabel: UILabel!
    
    @IBOutlet weak var checkOutButton: GradientButton!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
        
    var orders: [Order] = Order.getMyCartDummyOrders()
    var selectedOrder: Order?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUpStatefulTableView()
        self.selectFirstOrderByDefaultIfPossible()
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
    
    func selectFirstOrderByDefaultIfPossible() {
        if self.orders.count > 1 {
            self.selectedOrder = self.orders.first
            self.calculateBill(order:  self.orders.first!)
        } else {
            self.bottomView.isHidden = true
            self.bottomViewHeightConstraint.constant = 0
        }
    }
    


    func calculateBill(order: Order) {
        
        self.barNameLabel.text = order.barName
        
        var total: Double = 0.0
          
        for orderItem in order.orderItems {
            total += ( orderItem.unitPrice * Double(orderItem.quantity))
        }
                                    
        let priceString = String(format: "%.2f", total)
        let buttonTitle = "Checkout - £ " + priceString
        
        self.checkOutButton.setTitle(buttonTitle, for: .normal)
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
        let isSelected =  self.orders[section].barName == self.selectedOrder?.barName
        headerView?.setupHeader(title: self.orders[section].barName, isSelected: isSelected)
        headerView?.delegate = self
        headerView?.barId =  self.orders[section].barId
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
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
             debugPrint("IndexPath not found")
             return
         }
                
        let order = self.orders[indexPath.section]
        order.orderItems.remove(at: indexPath.item)
        self.orders[indexPath.section] = order

        if order.orderItems.count == 0 {
            self.orders.remove(at: indexPath.section)
            self.statefulTableView.innerTable.reloadData()
            self.selectFirstOrderByDefaultIfPossible()
        }
        self.calculateBill(order: order)

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

//MARK: CartSectionHeaderViewDelegate
extension MyCartViewController: CartSectionHeaderViewDelegate {
    func cartSectionHeaderView(view: CartSectionHeaderView, selectedBarId: String) {
      
        let filteredOrders = self.orders.filter { (order) -> Bool in
            return order.barId == selectedBarId
        }
       
        if filteredOrders.count > 0 {
            self.selectedOrder = filteredOrders.first!
            self.calculateBill(order: self.selectedOrder!)
        } else {
                debugPrint("some error finding the selected bar order")
        }

    }
}
