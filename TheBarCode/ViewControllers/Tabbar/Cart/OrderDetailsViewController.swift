//
//  OrderDetailsViewController.swift
//  TheBarCode
//
//  Created by Macbook on 20/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import ObjectMapper

class OrderDetailsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var tableFooterView: UIView!
    
    var order: Order!
    var viewModels: [OrderViewModel] = []
    
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Order # " + self.order.orderNo
        self.setUpStatefulTableView()
        self.setupViewModel()

        self.cancelBarButtonItem.image = self.cancelBarButtonItem.image?.withRenderingMode(.alwaysOriginal)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(didTriggerPullToRefresh(sender:)), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl
    }
    
    //MARK: My Methods
    func setUpStatefulTableView() {
        
       self.tableView.register(cellType: OrderInfoTableViewCell.self)
       self.tableView.register(cellType: OrderStatusTableViewCell.self)
       self.tableView.register(cellType: OrderPaymentTableViewCell.self)
       
       self.tableView.tableFooterView = UIView()
    }
    
    @objc func didTriggerPullToRefresh(sender: UIRefreshControl) {
        self.getOrderDetails()
    }
    
    func setupViewModel() {
        
        self.viewModels.removeAll()
       
        let orderStatusInfo = OrderStatusInfo(orderNo: self.order.orderNo, status: self.order.status)
        let orderStatusSection = OrderStatusSection(items: [orderStatusInfo])
        self.viewModels.append(orderStatusSection)
        
        let barInfo = BarInfo(barName: self.order.barName)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)

        let orderProductsSection = OrderProductsInfoSection(items: self.order.orderItems)
        self.viewModels.append(orderProductsSection)
        
        var total: Double = self.order.orderItems.reduce(0.0) { (result, item) -> Double in
            return result + (Double(item.quantity) * item.unitPrice)
        }
        
        var discountItems: [OrderDiscountInfo] = []
        
        if let voucher = self.order.voucher {
            var value: Double = 0.0
            if voucher.valueType == .amount {
                value = voucher.value
                total -= value
            } else if voucher.valueType == .percent {
                let discountableValue = min(20.0, total)
                value = discountableValue / 100.0 * voucher.value
                total -= value
            }
            
            let info = OrderDiscountInfo(title: voucher.text, price: value)
            discountItems.insert(info, at: 0)
        }
        
        if let offer = self.order.offer {
            var value: Double = 0.0
            if offer.valueType == .amount {
                value = offer.value
                total -= value
            } else if offer.valueType == .percent {
                let discountableValue = min(20.0, total)
                value = discountableValue / 100.0 * offer.value
                total -= value
            }
            
            let info = OrderDiscountInfo(title: offer.text, price: value)
            discountItems.insert(info, at: 0)
        }
        
        total = max(0.0, total)
        
        let orderDiscountSection = OrderDiscountSection(items: discountItems)
        self.viewModels.append(orderDiscountSection)
        
        if self.order.deliveryCharges > 0.0 {
            let orderDeliveryInfo = OrderDeliveryInfo(title: "Delivery Charges", price: self.order.deliveryCharges)
            let orderDeliveryInfoSection = OrderDeliveryInfoSection(items: [orderDeliveryInfo])
            self.viewModels.append(orderDeliveryInfoSection)
        }
        
        let orderTotalBillInfo = OrderTotalBillInfo(title: "Total", price: total)
        let orderTotalBillInfoSection = OrderTotalBillInfoSection(items: [orderTotalBillInfo])
        self.viewModels.append(orderTotalBillInfoSection)
        
        if order.paymentSplit.count > 1 {
            let paymentHeading = Heading(title: "PAYMENT SPLIT")
            let paymentHeadingSection = HeadingSection(items: [paymentHeading])
            self.viewModels.append(paymentHeadingSection)
            
            let currentUser = Utility.shared.getCurrentUser()!
            
            var paymentInfo: [OrderPaymentInfo] = []
            for paymentSplit in order.paymentSplit {
                
                let percent = total > 0.0 ? paymentSplit.amount / total * 100.0 : 0.0
                
                let info = OrderPaymentInfo(title: currentUser.userId.value == paymentSplit.id ? "YOU" : paymentSplit.name.uppercased(),
                                            percentage: percent,
                                            status: "PAID",
                                            price: paymentSplit.amount)
                paymentInfo.append(info)
            }
            
            let orderPaymentInfoSection = OrderPaymentInfoSection(items: paymentInfo)
            self.viewModels.append(orderPaymentInfoSection)
            
        }
        
        self.tableView.reloadData()
    }
    
    //MARK: IBActions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: Webserivces Methods
extension OrderDetailsViewController {
    func getOrderDetails() {
        self.refreshControl.beginRefreshing()
        
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathOrders + "/" + self.order.orderNo, method: .get) { (response, serverError, error) in
            self.refreshControl.endRefreshing()
            
            guard error == nil else {
                return
            }
            
            guard serverError == nil else {
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let details = (responseDict?["data"] as? [String : Any]) {
                let context = OrderMappingContext(type: .order)
                self.order = Mapper<Order>(context: context).map(JSON: details)
                self.setupViewModel()
                
                NotificationCenter.default.post(name: notificationNameOrderDidRefresh, object: self.order)
            }
        }
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension OrderDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let viewModel = self.viewModels[section]
        return viewModel.rowCount
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let viewModel = self.viewModels[indexPath.section]
        
        let isFirstCell = indexPath.row == 0
        let isLastCell = indexPath.row == viewModel.rowCount - 1
        
        if let section = viewModel as? OrderStatusSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderStatusTableViewCell.self)
            cell.setupCell(orderStatusInfo: section.items[indexPath.row], showSeparator: false)
            return cell

        } else if let section = viewModel as? BarInfoSection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(barInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
        
        } else if let section = viewModel as? OrderProductsInfoSection {
     
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderItem: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell

        } else if let section = viewModel as? OrderDiscountSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDiscountInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderDeliveryInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDeliveryInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderTotalBillInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderTotalBillInfo: section.items[indexPath.row], showSeparator: false)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? HeadingSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderStatusTableViewCell.self)
            cell.setupCell(heading: section.items[indexPath.row], showSeparator: section.shouldShowSeparator)
            return cell
            
        } else if let section = viewModel as? OrderPaymentInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderPaymentTableViewCell.self)
            cell.setupCell(orderPaymentInfo: section.items[indexPath.row], showSeparator: section.shouldShowSeparator)
            return cell
            
        } else {
            
            return UITableViewCell()
        
        }
    }
         
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
    }
}
