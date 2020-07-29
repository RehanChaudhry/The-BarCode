//
//  OrderDetailsViewController.swift
//  TheBarCode
//
//  Created by Macbook on 20/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView


class OrderDetailsViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    
    var order: Order!
    var viewModels: [OrderViewModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = self.order.orderNo
        self.setUpStatefulTableView()
        self.setupViewModel()

    }
    

     //MARK: My Methods
    func setUpStatefulTableView() {
         
         self.statefulTableView.innerTable.register(cellType: OrderInfoTableViewCell.self)
         self.statefulTableView.innerTable.register(cellType: OrderStatusTableViewCell.self)
         self.statefulTableView.innerTable.register(cellType: OrderPaymentTableViewCell.self)

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
     //    self.statefulTableView.innerTable.separatorStyle = .none

     }
    
    func setupViewModel() {
       
        let orderStatusInfo = OrderStatusInfo(orderNo: self.order.orderNo, status: self.order.status )
        let orderStatusSection = OrderStatusSection(items: [orderStatusInfo])
        self.viewModels.append(orderStatusSection)
        
        let barInfo = BarInfo(barName: self.order.barName)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)

        let orderProductsSection = OrderProductsInfoSection(items: self.order.orderItems)
        self.viewModels.append(orderProductsSection)

        let orderDiscountInfo1 = OrderDiscountInfo(title: "Standard offer redeem", price: -2.2)
        let orderDiscountInfo2 = OrderDiscountInfo(title: "Voucher - Buy one get one free", price: 0.0 )
        let orderDiscountSection = OrderDiscountSection(items: [orderDiscountInfo1, orderDiscountInfo2])
        self.viewModels.append(orderDiscountSection)
        
        let orderDeliveryInfo = OrderDeliveryInfo(title: "Delivery Charges", price: 3.2 )
        let orderDeliveryInfoSection = OrderDeliveryInfoSection(items: [orderDeliveryInfo])
        self.viewModels.append(orderDeliveryInfoSection)
        
        let orderTotalBillInfo = OrderTotalBillInfo(title: "Total", price: 23.0 )
        let orderTotalBillInfoSection = OrderTotalBillInfoSection(items: [orderTotalBillInfo])
        self.viewModels.append(orderTotalBillInfoSection)
        
        let paymentHeading = Heading(title: "PAYMENT SPLIT")
        let paymentHeadingSection = HeadingSection(items: [paymentHeading])
        self.viewModels.append(paymentHeadingSection)
        
        let orderPaymentInfo1 = OrderPaymentInfo(title: "BEN MILNES", percentage: 50, status: "Paid", price: 11.5)
        let orderPaymentInfo2 = OrderPaymentInfo(title: "YOU", percentage: 50, status: "Paid", price: 11.5)
        let orderPaymentInfoSection = OrderPaymentInfoSection(items: [orderPaymentInfo1, orderPaymentInfo2])
        self.viewModels.append(orderPaymentInfoSection)
        
    }
    
    //MARK: IBActions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension OrderDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
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
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
    }
}
