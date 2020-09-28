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
import Alamofire

class OrderDetailsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var cancelBarButtonItem: UIBarButtonItem!
    
    @IBOutlet var tableFooterView: UIView!
    
    var orderId: String?
    var order: Order?
    
    var viewModels: [OrderViewModel] = []
    
    var refreshControl: UIRefreshControl!

    var statefulView: LoadingAndErrorView!
    
    var dataRequest: DataRequest?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Order # " + self.getOrderId()
        self.setUpStatefulTableView()
        
        self.cancelBarButtonItem.image = self.cancelBarButtonItem.image?.withRenderingMode(.alwaysOriginal)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(didTriggerPullToRefresh(sender:)), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.statefulView.isHidden = true
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self](sender: UIButton) in
            self.getOrderDetails(isRefreshing: false)
        }
        
        self.statefulView.autoPinEdgesToSuperviewSafeArea()
        
        if self.orderId != nil {
            self.getOrderDetails(isRefreshing: false)
        } else {
            self.setupViewModel()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(orderStatusUpdatedNotification(notification:)), name: notificationNameOrderStatusUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameOrderStatusUpdated, object: nil)
    }
    
    //MARK: My Methods
    func setUpStatefulTableView() {
        
       self.tableView.register(cellType: OrderInfoTableViewCell.self)
       self.tableView.register(cellType: OrderStatusTableViewCell.self)
       self.tableView.register(cellType: OrderPaymentTableViewCell.self)
       
       self.tableView.tableFooterView = UIView()
    }
    
    func getOrderId() -> String {
        if let order = self.order {
            return order.orderNo
        } else if let orderId = self.orderId {
            return orderId
        } else {
            return ""
        }
    }
    
    @objc func didTriggerPullToRefresh(sender: UIRefreshControl) {
        self.getOrderDetails(isRefreshing: true)
    }
    
    func setupViewModel() {
        
        self.viewModels.removeAll()
       
        defer {
            self.tableView.reloadData()
        }
        
        guard let order = self.order else {
            return
        }
        
        var totalProductPrice = self.getProductsTotalPrice()
        
        let orderStatusInfo = OrderStatusInfo(orderNo: order.orderNo, status: order.statusRaw)
        let orderStatusSection = OrderStatusSection(items: [orderStatusInfo])
        self.viewModels.append(orderStatusSection)
        
        let barInfo = BarInfo(barName: order.barName, orderType: order.orderType)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)

        let orderProductsSection = OrderProductsInfoSection(items: order.orderItems)
        self.viewModels.append(orderProductsSection)

        if order.orderType == .delivery && order.deliveryCharges > 0.0 {
            let deliveryCharges = order.deliveryCharges
            
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
        
        let amount = order.paymentSplit.first?.amount ?? 0.0
        let discount = order.paymentSplit.first?.discount ?? 0.0
        
        var shouldAppendTotal: Bool = false
        
        if order.userId != currentUser.userId.value || order.paymentSplit.count > 1 {
            let splitAmountInfo = OrderBillInfo(title: "Your Splitted Amount", price: amount + discount)
            let orderAmountSplitBillInfoSection = OrderSplitAmountInfoSection(items: [splitAmountInfo])
            self.viewModels.append(orderAmountSplitBillInfoSection)
            
            shouldAppendTotal = true
        }
        
        var discountItems: [OrderDiscountInfo] = []
        if let voucher = order.voucher {
            let info = OrderDiscountInfo(title: voucher.text, price: voucher.discount)
            discountItems.append(info)
            
            shouldAppendTotal = true
        }
        
        if let offer = order.offer {
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
    }
    
    func getProductsTotalPrice() -> Double {
        
        guard let order = self.order else {
            return 0.0
        }
        
        let total: Double = order.orderItems.reduce(0.0) { (result, item) -> Double in
            return result + (Double(item.quantity) * item.unitPrice)
        }

        return total
    }
    
    //MARK: IBActions
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: Webserivces Methods
extension OrderDetailsViewController {
    func getOrderDetails(isRefreshing: Bool) {
        
        if isRefreshing {
            self.refreshControl.beginRefreshing()
        } else {
            self.statefulView.isHidden = false
            self.statefulView.showLoading()
        }
        
        self.dataRequest?.cancel()
        self.dataRequest = APIHelper.shared.hitApi(params: [:], apiPath: apiPathOrders + "/" + self.getOrderId(), method: .get) { (response, serverError, error) in
            self.refreshControl.endRefreshing()
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap to reload")
                return
            }
            
            guard serverError == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.detail, reloadMessage: "Tap to reload")
                return
            }
            
            self.statefulView.isHidden = true
            self.statefulView.showNothing()
            
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
            
        }  else if let section = viewModel as? OrderSplitAmountInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            
            let info = section.items[indexPath.row]
            let cornerRadius: CGFloat = info.shouldRoundCorners ? 8.0 : 0.0
            cell.setupCell(orderTotalBillInfo: info, showSeparator: !info.shouldRoundCorners, radius: cornerRadius)
            cell.adjustMargins(adjustTop: true, adjustBottom: true)
            
            if info.showWithBlackAppearance {
                cell.setupMainViewAppearanceAsBlack()
            } else {
                cell.setupMainViewAppearanceAsStandard()
            }
            
            return cell
            
        } else if let section = viewModel as? OrderDeliveryInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDeliveryInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderTotalBillInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            
            let info = section.items[indexPath.row]
            let cornerRadius: CGFloat = info.shouldRoundCorners ? 8.0 : 0.0
            
            cell.setupCell(orderTotalBillInfo: info, showSeparator: !info.shouldRoundCorners, radius: cornerRadius)
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

//MARK: Notification Methods
extension OrderDetailsViewController {
    @objc func orderStatusUpdatedNotification(notification: Notification) {
        if let id = notification.object as? String, self.getOrderId() == id {
            self.getOrderDetails(isRefreshing: self.order != nil)
        }
    }
}
