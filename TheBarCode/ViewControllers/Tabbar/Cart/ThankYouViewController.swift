//
//  ThankYouViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 12/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView

class ThankYouViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
   
    @IBOutlet var tableHeaderView: UIView!
    @IBOutlet var tableFooterView: UIView!
   
    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    
    var order: Order!
    var viewModels: [OrderViewModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Order # \(self.order.orderNo)"
        
        self.addBackButton()
        
        self.cancelBarButtonItem.image = self.cancelBarButtonItem.image?.withRenderingMode(.alwaysOriginal)
        
        self.setUpStatefulTableView()
        self.setupViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.statefulTableView.innerTable.reloadData()
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
        self.statefulTableView.innerTable.tableHeaderView = self.tableHeaderView
        self.statefulTableView.innerTable.tableFooterView = self.tableFooterView
        
     }
    
    func moveToOrderDetails() {
        let orderDetail = (self.storyboard!.instantiateViewController(withIdentifier: "OrderDetailsViewController") as! OrderDetailsViewController)
        orderDetail.order = self.order
        self.navigationController?.pushViewController(orderDetail, animated: true)
    }
    
    func setupViewModel() {
        
        self.viewModels.removeAll()
        
        var totalProductPrice = self.getProductsTotalPrice()
        
        let barInfo = BarInfo(barName: self.order.barName, orderType: self.order.orderType)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)

        self.viewModels.append(contentsOf: self.order.orderItems.map({ OrderProductsInfoSection(item: $0) }))

        if self.order.orderType == .delivery && self.order.deliveryCharges > 0.0 {
            let deliveryCharges = self.order.deliveryCharges
            
            let orderDeliveryInfo = OrderDeliveryInfo(title: "Delivery Charges", price: deliveryCharges)
            let orderDeliveryInfoSection = OrderDeliveryInfoSection(items: [orderDeliveryInfo])
            self.viewModels.append(orderDeliveryInfoSection)
            
            totalProductPrice += deliveryCharges
        }
        
        let orderTotalBillInfo = OrderBillInfo(title: "Grand Total", price: totalProductPrice)
        orderTotalBillInfo.shouldRoundCorners = true
        orderTotalBillInfo.showWithBlackAppearance = true
        
        let orderTotalBillInfoSection = OrderTotalBillInfoSection(items: [orderTotalBillInfo])
        self.viewModels.append(orderTotalBillInfoSection)
        
        let currentUser = Utility.shared.getCurrentUser()!
        
        let amount = self.order.paymentSplit.first?.amount ?? 0.0
        let discount = self.order.paymentSplit.first?.discount ?? 0.0
        
        var shouldAppendTotal: Bool = false
        
        if order.userId != currentUser.userId.value || order.paymentSplit.count > 1 {
            let splitAmountInfo = OrderBillInfo(title: "Your Splitted Amount", price: amount + discount)
            let orderAmountSplitBillInfoSection = OrderSplitAmountInfoSection(items: [splitAmountInfo])
            self.viewModels.append(orderAmountSplitBillInfoSection)
            
            shouldAppendTotal = true
        }
        
        var discountItems: [OrderDiscountInfo] = []
        if let voucher = self.order.voucher {
            let info = OrderDiscountInfo(title: voucher.text, price: voucher.discount)
            discountItems.append(info)
            
            shouldAppendTotal = true
        }
        
        if let offer = self.order.offer {
            let info = OrderDiscountInfo(title: offer.text, price: offer.discount)
            discountItems.append(info)
            
            shouldAppendTotal = true
        }

        let orderDiscountSection = OrderDiscountSection(items: discountItems)
        self.viewModels.append(orderDiscountSection)
        
        if shouldAppendTotal {
            let splitTotalInfo = OrderBillInfo(title: "Total Paid", price: amount)
            splitTotalInfo.shouldRoundCorners = true
            splitTotalInfo.showWithBlackAppearance = true
            
            orderTotalBillInfo.shouldRoundCorners = false
            
            let orderTotalSplitBillInfoSection = OrderSplitAmountInfoSection(items: [splitTotalInfo])
            self.viewModels.append(orderTotalSplitBillInfoSection)
        }

        if order.userId != currentUser.userId.value || order.paymentSplit.count > 1 {
            
            let paymentHeading = Heading(title: "BILL SPLIT")
            let paymentHeadingSection = HeadingSection(items: [paymentHeading])
            self.viewModels.append(paymentHeadingSection)

            var paymentInfo: [OrderPaymentInfo] = []
            for paymentSplit in order.paymentSplit {
                
                let amount = paymentSplit.amount + paymentSplit.discount
                let percent = totalProductPrice > 0.0 ? amount / totalProductPrice * 100.0 : 0.0
                
                let info = OrderPaymentInfo(title: currentUser.userId.value == paymentSplit.id ? "YOU" : paymentSplit.name.uppercased(),
                                            percentage: percent,
                                            statusRaw: PaymentStatus.paid.rawValue,
                                            price: amount)
                paymentInfo.append(info)
            }
            
            let orderPaymentInfoSection = OrderPaymentInfoSection(items: paymentInfo)
            self.viewModels.append(orderPaymentInfoSection)
            
        }
        
        
        self.statefulTableView.innerTable.reloadData()
    }
    
    func getProductsTotalPrice() -> Double {
        
        let total: Double = self.order.orderItems.reduce(0.0) { (result, item) -> Double in
            return result + item.totalPrice
        }

        return total
    }
    
    //MARK: My IBActions
    @IBAction func closeBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func viewOrderStatusButtonTapped(sender: UIButton) {
        self.moveToOrderDetails()
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension ThankYouViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
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
            
            let isLastOrderItem = self.order?.orderItems.last === section.item
            
            let item = section.rows[indexPath.row]
            if let item = item as? OrderItem {
                let isFirstOrderItem = item === self.order?.orderItems.first
                cell.setupCell(orderItem: item,
                               showSeparator: (isLastOrderItem && !section.isExpanded),
                               isExpanded: section.isExpanded,
                               hasSelectedModifiers: section.isExpandable,
                               currencySymbol: self.order.currencySymbol)
                cell.adjustMargins(top: isFirstOrderItem ? 16.0 : 8.0, bottom: (isLastOrderItem && !section.isExpanded) ? 16.0 : 4.0)
            } else if let item = item as? ProductModifier {
                cell.setupCell(modifier: item, showSeparator: (isLastOrderItem && isLastCell), currencySymbol: self.order.currencySymbol)
                cell.adjustMargins(top: 4.0, bottom: (isLastOrderItem && isLastCell) ? 16.0 : 4.0)
                return cell
            }
            
            return cell

        } else if let section = viewModel as? OrderDiscountSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDiscountInfo: section.items[indexPath.row], showSeparator: isLastCell, currencySymbol: self.order.currencySymbol)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        }  else if let section = viewModel as? OrderSplitAmountInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            
            let info = section.items[indexPath.row]
            let cornerRadius: CGFloat = info.shouldRoundCorners ? 8.0 : 0.0
            cell.setupCell(orderTotalBillInfo: info, showSeparator: !info.shouldRoundCorners, radius: cornerRadius, currencySymbol: self.order.currencySymbol)
            cell.adjustMargins(adjustTop: true, adjustBottom: true)
            
            if info.showWithBlackAppearance {
                cell.setupMainViewAppearanceAsBlack()
            } else {
                cell.setupMainViewAppearanceAsStandard()
            }
            
            return cell
            
        } else if let section = viewModel as? OrderDeliveryInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDeliveryInfo: section.items[indexPath.row], showSeparator: isLastCell, currencySymbol: self.order.currencySymbol)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderTotalBillInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            
            let info = section.items[indexPath.row]
            let cornerRadius: CGFloat = info.shouldRoundCorners ? 8.0 : 0.0
            
            cell.setupCell(orderTotalBillInfo: info, showSeparator: !info.shouldRoundCorners, radius: cornerRadius, currencySymbol: self.order.currencySymbol)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            
            if info.showWithBlackAppearance {
                cell.setupMainViewAppearanceAsBlack()
            } else {
                cell.setupMainViewAppearanceAsStandard()
            }
            
            return cell
            
        } else if let section = viewModel as? HeadingSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderStatusTableViewCell.self)
            cell.setupCell(heading: section.items[indexPath.row], showSeparator: section.shouldShowSeparator)
            return cell
            
        } else if let section = viewModel as? OrderPaymentInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderPaymentTableViewCell.self)
            cell.setupCell(orderPaymentInfo: section.items[indexPath.row], showSeparator: section.shouldShowSeparator, currencySymbol: self.order.currencySymbol)
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
         
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        let viewModel = self.viewModels[indexPath.section]
        
        if let viewModel = viewModel as? OrderProductsInfoSection,
            viewModel.isExpandable,
            let _ = viewModel.rows[indexPath.row] as? OrderItem {
            viewModel.isExpanded = !viewModel.isExpanded
            self.statefulTableView.innerTable.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
}
