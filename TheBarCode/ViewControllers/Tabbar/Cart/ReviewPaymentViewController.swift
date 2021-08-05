//
//  ReviewPaymentViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 12/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import ObjectMapper
import Alamofire

class ReviewPaymentViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
   
    @IBOutlet var payButton: UIButton!
    
    var orderId: String!
    
    var order: Order?
    
    var viewModels: [OrderViewModel] = []
    
    var totalBillPayable: Double = 0.0
    
    var splitPaymentyInfo : PaymentSplit!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Review"
        
        //orderTip = Double(order!.orderTip) ?? 0.0

        self.addBackButton()
        
        self.payButton.setTitle("Confirm Pay", for: .normal)
        //self.order!.paymentSplit.append(self.splitPaymentyInfo)
        self.setUpStatefulTableView()
        self.statefulTableView.triggerInitialLoad()
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
        self.statefulTableView.statefulDelegate = self
        
        self.statefulTableView.backgroundColor = .clear
        for aView in self.statefulTableView.subviews {
            aView.backgroundColor = .clear
        }
        
        self.statefulTableView.canLoadMore = false
        self.statefulTableView.canPullToRefresh = false
        self.statefulTableView.innerTable.rowHeight = UITableViewAutomaticDimension
        self.statefulTableView.innerTable.estimatedRowHeight = 200.0
        self.statefulTableView.innerTable.tableFooterView = UIView()
        
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 16))
        tableHeaderView.backgroundColor = UIColor.clear
        self.statefulTableView.innerTable.tableHeaderView = tableHeaderView

    }
    
    func setupViewModels() {
        
        defer {
            self.statefulTableView.innerTable.reloadData()
        }
        
        self.viewModels.removeAll()
        guard let order = self.order else {
            return
        }
        
        let barInfo = BarInfo(barName: order.barName, orderType: order.orderType)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)

        self.viewModels.append(contentsOf: order.orderItems.map({ OrderProductsInfoSection(item: $0) }))
        
        let tipInfo = OrderTipInfo(title: "Tip", tipAmount: self.order!.orderTip)
        let tipInfoSection = OrderTipInfoSection(items: [tipInfo])
        self.viewModels.append(tipInfoSection)
        
        var total: Double = order.orderItems.reduce(0.0) { (result, item) -> Double in
            return result + item.totalPrice
        }
        
        
        let orderTotalBillInfo = OrderBillInfo(title: "Grand Total", price: total + self.order!.orderTip)
        let orderTotalBillInfoSection = OrderTotalBillInfoSection(items: [orderTotalBillInfo])
        self.viewModels.append(orderTotalBillInfoSection)
        
        if order.paymentSplit.count != 1 {
        var paidAmount: Double = 0.0
        if order.paymentSplit.count > 0 {
            
            let splitAmountInfo = OrderBillInfo(title: "Your Splitted Amount", price: 0.0)
            let splitTotalInfo = OrderBillInfo(title: "Total", price: 0.0)
            let orderSplitBillInfoSection = OrderSplitAmountInfoSection(items: [splitAmountInfo, splitTotalInfo])
            self.viewModels.append(orderSplitBillInfoSection)
            
            let paymentHeading = Heading(title: "BILL SPLIT")
            let paymentHeadingSection = HeadingSection(items: [paymentHeading])
            self.viewModels.append(paymentHeadingSection)
            
           
                
            
            
            let currentUser = Utility.shared.getCurrentUser()!
            
            var paymentInfo: [OrderPaymentInfo] = []
            for paymentSplit in order.paymentSplit {
                
                var count: Int = 1
                if order.paymentSplit.count == 1 {
                    count = 0
                }
                let splittedAmount = order.paymentSplit[count].amount
                let amount = paymentSplit.amount + paymentSplit.discount
                if paidAmount == 0.0 {
                    paidAmount += total - splittedAmount
                }
                
                let percent: Double
                if (amount > paidAmount) {
                 percent = total > 0.0 ? (amount - paidAmount) / total * 100.0 : 0.0
                }
                else{
                     percent = total > 0.0 ? (paidAmount - amount) / total * 100.0 : 0.0
                    paidAmount -= amount
                }
                
                let info = OrderPaymentInfo(title: currentUser.userId.value == paymentSplit.id ? "YOU" : paymentSplit.name.uppercased(),
                                            percentage: percent,
                                            statusRaw: PaymentStatus.paid.rawValue,
                                            price: paidAmount)
                
                
                
                paymentInfo.append(info)
                
                if (count < order.paymentSplit.count) {
                count += 1
                }
                
                if paidAmount != amount {
                paidAmount = 0
                paidAmount += amount - paidAmount
                }
            }
            
            let orderPaymentInfoSection = OrderPaymentInfoSection(items: paymentInfo)
            self.viewModels.append(orderPaymentInfoSection)
            
            let leftAmount = total - paidAmount
            
            splitAmountInfo.price = leftAmount
            splitTotalInfo.price = leftAmount

            self.order?.splitPaymentInfo = (type: .none, value: leftAmount)
        }
        total -= paidAmount
        }
        self.totalBillPayable = max(0.0, total)
        self.payButton.setTitle(String(format: "Confirm Pay - \(order.currencySymbol) %.2f", self.totalBillPayable + self.order!.orderTip), for: .normal)
    }
    
    //MARK: My IBActions
    @IBAction func payButtonTapped(sender: UIButton) {
        
        guard let order = self.order else {
            return
        }
        
        let controller = (self.storyboard!.instantiateViewController(withIdentifier: "CheckOutViewController") as! CheckOutViewController)
        
        controller.totalBillPayable = self.totalBillPayable
        //controller.orderTip = self.orderTip
        controller.withOutSplittotalBillPayable = self.totalBillPayable
        controller.order = self.order
        controller.order = order
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension ReviewPaymentViewController: UITableViewDataSource, UITableViewDelegate {
    
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
                               currencySymbol: self.order!.currencySymbol)
                cell.adjustMargins(top: isFirstOrderItem ? 16.0 : 8.0, bottom: (isLastOrderItem && !section.isExpanded) ? 16.0 : 4.0)
            } else if let item = item as? ProductModifier {
                cell.setupCell(modifier: item, showSeparator: (isLastOrderItem && isLastCell), currencySymbol: self.order!.currencySymbol)
                cell.adjustMargins(top: 4.0, bottom: (isLastOrderItem && isLastCell) ? 16.0 : 4.0)
                return cell
            }
            
            return cell

        }
        
        else if let section = viewModel as? OrderTipInfoSection {
             let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
         cell.setupCell(orderTipInfo: section.items[indexPath.row], showSeparator: false, currencySymbol: self.order!.currencySymbol)
         cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
             return cell
         }
        
        else if let section = viewModel as? OrderDiscountSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDiscountInfo: section.items[indexPath.row], showSeparator: isLastCell, currencySymbol: self.order!.currencySymbol)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderDeliveryInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDeliveryInfo: section.items[indexPath.row], showSeparator: isLastCell, currencySymbol: self.order!.currencySymbol)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderTotalBillInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            
            let cornerRadius: CGFloat = self.order!.paymentSplit.count == 0 ? 8.0 : 0.0
            cell.setupCell(orderTotalBillInfo: section.items[indexPath.row], showSeparator: self.order!.paymentSplit.count > 0, radius: cornerRadius, currencySymbol: self.order!.currencySymbol)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            
            return cell
            
        } else if let section = viewModel as? OrderSplitAmountInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            
            let cornerRadius: CGFloat = isLastCell ? 8.0 : 0.0
            cell.setupCell(orderTotalBillInfo: section.items[indexPath.row], showSeparator: !isLastCell, radius: cornerRadius, currencySymbol: self.order!.currencySymbol)
            cell.adjustMargins(adjustTop: true, adjustBottom: true)
            
            if isLastCell {
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
            
            cell.setupCell(orderPaymentInfo: section.items[indexPath.row], showSeparator: section.shouldShowSeparator, currencySymbol: self.order!.currencySymbol, orderTip: self.order!.paymentSplit[indexPath.item].orderTip ?? 0.0)
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

//MARK: Webservices Methods
extension ReviewPaymentViewController {
    func getOrderDetails(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        let params:[String : Any] =  [:]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathOrders + "/" + self.orderId, method: .get) { (response, serverError, error) in
    
            defer {
                self.setupViewModels()
            }
            
            guard error == nil else {
                completion(error! as NSError)
                return
            }
            
            guard serverError == nil else {
                completion(serverError!.nsError())
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseObject = (responseDict?["data"] as? [String : Any]) {
                
                let context = OrderMappingContext(type: .order)
                let order = Mapper<Order>(context: context).map(JSON: responseObject)
                
                self.order = order
                self.order!.paymentSplit.insert(self.splitPaymentyInfo, at: 0)
                
                self.statefulTableView.canPullToRefresh = true
                
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
}

//MARK: StatefulTableDelegate
extension ReviewPaymentViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getOrderDetails(isRefreshing: false) {  [unowned self] (error) in
            handler(self.order == nil, error)
        }
        
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.getOrderDetails(isRefreshing: false) { (error) in
            handler(false, error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getOrderDetails(isRefreshing: true) { [unowned self] (error) in
            handler(self.order == nil, error)
        }
    }
    
    func statefulTableViewViewForInitialLoad(tvc: StatefulTableView) -> UIView? {
        let initialErrorView = LoadingAndErrorView.loadFromNib()
        initialErrorView.backgroundColor = self.view.backgroundColor
        initialErrorView.showLoading()
        return initialErrorView
    }
    
    func statefulTableViewInitialErrorView(tvc: StatefulTableView, forInitialLoadError: NSError?) -> UIView? {
        if forInitialLoadError == nil {
            let title = "Order Not Found"
            let subTitle = "Tap to refresh"
            
            let emptyDataView = EmptyDataView.loadFromNib()
            emptyDataView.backgroundColor = self.view.backgroundColor
            emptyDataView.setTitle(title: title, desc: subTitle, iconImageName: "icon_loading", buttonTitle: "")
            
            emptyDataView.actionHandler = { (sender: UIButton) in
                tvc.triggerInitialLoad()
            }
            
            return emptyDataView
            
        } else {
            let initialErrorView = LoadingAndErrorView.loadFromNib()
            initialErrorView.showErrorView(canRetry: true)
            initialErrorView.backgroundColor = self.view.backgroundColor
            initialErrorView.showErrorViewWithRetry(errorMessage: forInitialLoadError!.localizedDescription, reloadMessage: "Tap to refresh")
            
            initialErrorView.retryHandler = {(sender: UIButton) in
                tvc.triggerInitialLoad()
            }
            
            return initialErrorView
        }
    }
    
    func statefulTableViewLoadMoreErrorView(tvc: StatefulTableView, forLoadMoreError: NSError?) -> UIView? {
        let loadingView = LoadingAndErrorView.loadFromNib()
        loadingView.showErrorView(canRetry: true)
        loadingView.backgroundColor = self.view.backgroundColor
        
        if forLoadMoreError == nil {
            loadingView.showLoading()
        } else {
            loadingView.showErrorViewWithRetry(errorMessage: forLoadMoreError!.localizedDescription, reloadMessage: "Tap to refresh")
        }
        
        loadingView.retryHandler = {(sender: UIButton) in
            tvc.triggerLoadMore()
        }
        
        return loadingView
    }
}

