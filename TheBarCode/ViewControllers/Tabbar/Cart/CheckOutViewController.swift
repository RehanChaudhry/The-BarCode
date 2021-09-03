//
//  CheckOutViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 03/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import Reusable
import ObjectMapper
import Alamofire
import MLLabel

class CheckOutViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var footerView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var checkoutButton: UIButton!
    
    var viewModels: [OrderViewModel] = []
    
    var vouchers: [OrderDiscount] = []
    var offers: [OrderDiscount] = []
    
    var order: Order!
    
    var totalBillPayable: Double = 0.0
    var withOutSplittotalBillPayable: Double = 0.0
    
    var refreshControl: UIRefreshControl!
    
    var isGettingVouchers: Bool = false {
        didSet {
            self.updateLoader()
        }
    }
    
    var isGettingOffers: Bool = false {
        didSet {
            self.updateLoader()
        }
    }
    
    var message: NSAttributedString?
    
    var offerRequest: DataRequest?
    var voucherRequest: DataRequest?
    
    var reloadScheme: String = "reload"
    
    var useCredit: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        self.setUpStatefulTableView()

        self.getVouchers()
        self.getOffers()
        
        self.setupViewModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadSuccessfullNotification(notification:)), name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(rawValue: notificationNameReloadSuccess), object: nil)
    }
    
    //MARK: My Methods
    func setUpStatefulTableView() {
           
        self.tableView.register(cellType: OrderInfoTableViewCell.self)
        self.tableView.register(cellType: OrderStatusTableViewCell.self)
        self.tableView.register(cellType: OrderRadioButtonTableViewCell.self)
        self.tableView.register(cellType: OrderOfferRedeemTableViewCell.self)
        self.tableView.register(cellType: OrderOfferDiscountTableViewCell.self)
        self.tableView.register(cellType: OrderMessageTableViewCell.self)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.tableFooterView = self.footerView
        
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 16))
        tableHeaderView.backgroundColor = UIColor.clear
        self.tableView.tableHeaderView = tableHeaderView
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(didTriggerPullToRefresh(sender:)), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl
    }
    
    @objc func didTriggerPullToRefresh(sender: UIRefreshControl) {
        self.getOffers()
        self.getVouchers()
    }
    
    func setupViewModel() {
        
        self.viewModels.removeAll()
        let barInfo = BarInfo(barName: self.order.barName, orderType: self.order.orderType)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)

        self.viewModels.append(contentsOf: self.order.orderItems.map({ OrderProductsInfoSection(item: $0) }))
        
        if self.order.orderType == .delivery {
            let deliveryCharges = Utility.shared.getDeliveryCharges(order: self.order, totalPrice: self.getProductsTotalPrice())
            
            let orderDeliveryInfo = OrderDeliveryInfo(title: "Delivery Charges", price: deliveryCharges)
            let orderDeliveryInfoSection = OrderDeliveryInfoSection(items: [orderDeliveryInfo])
            self.viewModels.append(orderDeliveryInfoSection)
        }
        
        if self.order.orderTip != 0.0 {
        
        if self.order.orderType.rawValue == "dine_in" || self.order.orderType.rawValue ==  "collection" {
        
                let tipInfo = OrderTipInfo(title: "Tip", tipAmount: self.order!.orderTip)
                let tipInfoSection = OrderTipInfoSection(items: [tipInfo])
                self.viewModels.append(tipInfoSection)
        }
        }
        
        
        let orderTotalBillInfo = OrderBillInfo(title: "Grand Total", price: 0.0)
        let orderTotalBillInfoSection = OrderTotalBillInfoSection(items: [orderTotalBillInfo])
        self.viewModels.append(orderTotalBillInfoSection)
        
        if let splitInfo = self.order.splitPaymentInfo {
            let splitAmountInfo = OrderBillInfo(title: "Your Splitted Amount", price: splitInfo.value)
            let splitTotalInfo = OrderBillInfo(title: "Total", price: splitInfo.value)
            let orderSplitBillInfoSection = OrderSplitAmountInfoSection(items: [splitAmountInfo, splitTotalInfo])
            self.viewModels.append(orderSplitBillInfoSection)
        }
        
        if !self.isGettingOffers && !self.isGettingVouchers {
//            let redeemOfferHeading = Heading(title: "Redeem Available Vouchers")
//            let redeemOfferHeadingSection = HeadingSection(items: [redeemOfferHeading])
//            self.viewModels.append(redeemOfferHeadingSection)
//
//            let voucherNone = OrderDiscount(JSON: ["id" : 0])!
//            voucherNone.text = "None"
//            voucherNone.isSelected = true
//
//            self.vouchers = self.vouchers.map({ (discount) -> OrderDiscount in
//                discount.isSelected = false
//                discount.shouldShowValue = true
//                return discount
//            })
//
//            let vouchersSection = OrderOffersSection(type: .vouchers, items: [voucherNone] + self.vouchers)
//            self.viewModels.append(vouchersSection)
            
            let standardOfferHeading = Heading(title: "Redeem Available Offers")
            let standardOfferHeadingSection = HeadingSection(items: [standardOfferHeading])
            self.viewModels.append(standardOfferHeadingSection)
            
            let offerNone = OrderDiscount(JSON: ["id" : 0])!
            offerNone.text = "None"
            offerNone.isSelected = true
            
            self.offers = self.offers.map({ (discount) -> OrderDiscount in
                discount.isSelected = false
                return discount
            })
            
            let offersSection = OrderOffersSection(type: .offers, items: [offerNone] + self.offers)
            self.viewModels.append(offersSection)
            
            let discountInfoSection = OrderOfferDiscountSection(type: .discountInfo, items: [])
            self.viewModels.append(discountInfoSection)
            
            if let message = self.message {
                let messageInfo = OrderMessage(message: message)
                let messageSection = OrderMessageSection(items: [messageInfo])
                self.viewModels.append(messageSection)
            }
            
//            let redeemButton = OrderOfferRedeem(title: "Redeem", enable: (self.offers.count > 0 || self.vouchers.count > 0))
//            let offerRedeemSection = OrderOfferRedeemSection(type: .offerRedeem, items: [redeemButton])
//            self.viewModels.append(offerRedeemSection)
        }
    
        self.tableView.reloadData()
        self.calculateTotal()
    }

    func getProductsTotalPrice() -> Double {
        
        let total: Double = self.order.orderItems.reduce(0.0) { (result, item) -> Double in
            return result + item.totalPrice
        }

        return total
    }
    
    func calculateTotal() {
        
        var totalPayablePrice = self.getProductsTotalPrice()
        var grandTotal = totalPayablePrice
        
        let selectedVoucher = (self.viewModels.first(where: {$0.type == .vouchers}) as? OrderOffersSection)?.items.first(where: {$0.isSelected})
        let selectedOffer = (self.viewModels.first(where: {$0.type == .offers}) as? OrderOffersSection)?.items.first(where: {$0.isSelected})
        
        if let splitValue = self.order.splitPaymentInfo?.value {
            totalPayablePrice = splitValue
        }
        
        var voucherDiscount: Double = 0.0
        if let selectedVoucher = selectedVoucher, selectedVoucher.value > 0.0 {
            if selectedVoucher.valueType == .percent {
                voucherDiscount = ((min(20.0, totalPayablePrice) / 100.0) * selectedVoucher.value)
            } else if selectedVoucher.valueType == .amount {
                voucherDiscount = selectedVoucher.value
            }
            
            totalPayablePrice -= voucherDiscount
        }
        
        var offerDiscount: Double = 0.0
        if let selectedOffer = selectedOffer, selectedOffer.value > 0 {
            if selectedOffer.valueType == .percent {
                offerDiscount = ((min(20.0, totalPayablePrice) / 100.0) * selectedOffer.value)
            } else if selectedOffer.valueType == .amount {
                offerDiscount = selectedOffer.value
            }
            
            totalPayablePrice -= offerDiscount
        }
        
        if let deliverySection = self.viewModels.first(where: {$0.type == .deliveryChargesDetails}) as? OrderDeliveryInfoSection,
            let deliveryItem = deliverySection.items.first {
            totalPayablePrice += deliveryItem.price
            grandTotal += deliveryItem.price
        }
        
        totalPayablePrice = max(0, totalPayablePrice)
        
        if let totalSectionIndex = self.viewModels.firstIndex(where: {$0.type == .totalBill}) {
            (self.viewModels[totalSectionIndex] as! OrderTotalBillInfoSection).items.first?.price = grandTotal + self.order!.orderTip
            let indexPath = IndexPath(row: 0, section: totalSectionIndex)
            
            if self.tableView.numberOfSections > 0 {
                UIView.performWithoutAnimation {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            } else {
                self.tableView.reloadData()
            }
        }
        
        if let splitPayment = self.order.splitPaymentInfo {
            let splitPaymentValue = splitPayment.value
            self.totalBillPayable = max(0.0, splitPaymentValue - (voucherDiscount + offerDiscount))
        } else {
            
            var paidAmount: Double = 0.0
            if self.order.paymentSplit.count > 0 {
                for paymentSplit in order.paymentSplit {
                    let amount = paymentSplit.amount + paymentSplit.discount
                    paidAmount += amount
                }
            }
            
            //totalPayablePrice -= paidAmount
            self.totalBillPayable = max(0.0, totalPayablePrice)
            self.withOutSplittotalBillPayable = totalBillPayable
        }
        
        var splittedOrderTip: Double = 0.0
        if self.order.paymentSplit.count != 0 {
        let currentUser = Utility.shared.getCurrentUser()!
        
        
        for paymentSPlitInfo in self.order.paymentSplit {
            
            if currentUser.userId.value == paymentSPlitInfo.id {
                splittedOrderTip = paymentSPlitInfo.orderTip ?? 0.0
            }
        }
            self.checkoutButton.setTitle(String(format: "Continue - \(self.order.currencySymbol) %.2f", self.totalBillPayable + splittedOrderTip), for: .normal)
        }
        else {
            self.checkoutButton.setTitle(String(format: "Continue - \(self.order.currencySymbol) %.2f", self.totalBillPayable + self.order!.orderTip), for: .normal)
        }
        
    }
    
    func updateLoader() {
        if (!self.refreshControl.isRefreshing) && (self.isGettingVouchers || self.isGettingOffers) {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func setUpOffersAndVouchers() {
        if !self.isGettingOffers && !self.isGettingVouchers {
            self.setupViewModel()
            self.refreshControl.endRefreshing()
        }
    }
    
    func moveToReloadVC() {
        let reloadNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "ReloadNavigation") as! UINavigationController)
        reloadNavigation.modalPresentationStyle = .fullScreen
        
        let reloadController = reloadNavigation.viewControllers.first as! ReloadViewController
        reloadController.isRedeemingDeal = true
        reloadController.shouldAutoDismissOnReload = true
        self.present(reloadNavigation, animated: true, completion: nil)
    }
    
    func handleRedeemTapped() {
        let vouchers = self.viewModels.first(where: {$0.type == .vouchers}) as? OrderOffersSection
            let offers = self.viewModels.first(where: {$0.type == .offers}) as? OrderOffersSection
        
            let total = self.order.splitPaymentInfo?.value ?? self.getProductsTotalPrice()
            
            var totalExcludingVoucher = total
            
            if let index = self.viewModels.firstIndex(where: {$0.type == .discountInfo}) {
                
                let discountSection = self.viewModels[index] as! OrderOfferDiscountSection
                discountSection.items.removeAll()
                
                var voucherItems = vouchers?.items ?? []
                if voucherItems.count > 0 {
                    voucherItems.removeFirst()
                }
                
                var offerItems = offers?.items ?? []
                if offerItems.count > 0 {
                    offerItems.removeFirst()
                }
                
                func addHeadingIfNeeded() {
                    if discountSection.items.count == 0 {
                        let heading = OrderOfferDiscountInfo(title: "OFFER", value: 0.0, isHeading: true)
                        discountSection.items.append(heading)
                    }
                }
                
                if let selectedVoucher = voucherItems.first(where: {$0.isSelected}) {
                    addHeadingIfNeeded()
                    
                    let voucher = OrderOfferDiscountInfo(title: selectedVoucher.text, value: 0.0, isHeading: false)
                    if selectedVoucher.valueType == .percent {
                        let saving = ((min(20, total) / 100.0) * selectedVoucher.value)
                        voucher.value = saving
                    } else if selectedVoucher.valueType == .amount {
                        let saving = selectedVoucher.value
                        voucher.value = saving
                    }
                    
                    discountSection.items.append(voucher)
                    
                    totalExcludingVoucher = max(0, totalExcludingVoucher - voucher.value)
                }
                
                if let selectedOffer = offerItems.first(where: {$0.isSelected}) {
                    addHeadingIfNeeded()
                    
                    let offer = OrderOfferDiscountInfo(title: selectedOffer.text, value: 0.0, isHeading: false)
                    if selectedOffer.valueType == .percent {
                        let saving = ((min(20, totalExcludingVoucher) / 100.0) * selectedOffer.value)
                        offer.value = saving
                    } else if selectedOffer.valueType == .amount {
                        let saving = selectedOffer.value
                        offer.value = saving
                    }
                    
                    discountSection.items.append(offer)
                }
                            
                let indexSet = IndexSet(integer: index)
                self.tableView.reloadSections(indexSet, with: .fade)

            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [unowned self] in
                self.calculateTotal()
            }
    }
    
    //MARK: My IBActions
    
    @IBAction func continueButtonTapped(sender: UIButton) {
        
        var voucherItems: [OrderDiscount] = []
        voucherItems.append(contentsOf: (self.viewModels.first(where: {$0.type == .vouchers}) as? OrderOffersSection)?.items ?? [])
        if voucherItems.count > 0 {
            voucherItems.removeFirst()
        }
        
        
        var offerItems: [OrderDiscount] = []
        offerItems.append(contentsOf: (self.viewModels.first(where: {$0.type == .offers}) as? OrderOffersSection)?.items ?? [])
        if offerItems.count > 0 {
            offerItems.removeFirst()
        }

        let selectedVoucher = voucherItems.first(where: {$0.isSelected})
        let selectedOffer = offerItems.first(where: {$0.isSelected})
            
        let paymentController = (self.storyboard!.instantiateViewController(withIdentifier: "SavedCardsViewController") as! SavedCardsViewController)
        paymentController.order = self.order
        paymentController.totalBillPayable = self.totalBillPayable
        paymentController.withOutSplittotalBillPayable = self.withOutSplittotalBillPayable
        paymentController.selectedVoucher = selectedVoucher
        paymentController.selectedOffer = selectedOffer
        paymentController.useCredit = self.useCredit
        self.navigationController?.pushViewController(paymentController, animated: true)
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension CheckOutViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
        if let section = viewModel as? BarInfoSection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(barInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
        
        } else if let section = viewModel as? OrderProductsInfoSection {
     
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            
            let isLastOrderItem = self.order?.orderItems.last === section.item
            
            let item = section.rows[indexPath.row]
            if let item = item as? OrderItem {
                let isFirstOrderItem = item === self.order.orderItems.first
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

        }
        
        else if let section = viewModel as? OrderTipInfoSection {
             let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
         cell.setupCell(orderTipInfo: section.items[indexPath.row], showSeparator: false, currencySymbol: self.order!.currencySymbol)
         cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
             return cell
         }
        
        else if let section = viewModel as? OrderTotalBillInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            
            let cornerRadius: CGFloat = self.order.splitPaymentInfo == nil ? 8.0 : 0.0
            cell.setupCell(orderTotalBillInfo: section.items[indexPath.row], showSeparator: self.order.splitPaymentInfo == nil ? false : true, radius: cornerRadius, currencySymbol: self.order.currencySymbol)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            
            return cell
            
        } else if let section = viewModel as? OrderSplitAmountInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            
            let cornerRadius: CGFloat = isLastCell ? 8.0 : 0.0
            cell.setupCell(orderTotalBillInfo: section.items[indexPath.row], showSeparator: !isLastCell, radius: cornerRadius, currencySymbol: self.order.currencySymbol)
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
            
        } else if let section = viewModel as? OrderOffersSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderRadioButtonTableViewCell.self)
            cell.setupCell(orderOfferInfo: section.items[indexPath.row], showSeparator: (isLastCell && section.type == .vouchers), currencySymbol: self.order.currencySymbol)
            cell.delegate = self
            return cell
            
        } else if let section = viewModel as? OrderOfferRedeemSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderOfferRedeemTableViewCell.self)
            cell.setUpCell(orderOfferRedeem: section.items[indexPath.row])
            cell.delegate = self
            return cell
            
        } else if let section = viewModel as? OrderOfferDiscountSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderOfferDiscountTableViewCell.self)
            cell.setUpCell(discountInfo: section.items[indexPath.row], isFirst: isFirstCell, isLast: isLastCell, currencySymbol: self.order.currencySymbol)
            return cell
            
        } else if let section = viewModel as? OrderDeliveryInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDeliveryInfo: section.items[indexPath.row], showSeparator: isLastCell, currencySymbol: self.order.currencySymbol)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderMessageSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderMessageTableViewCell.self)
            cell.setUpCell(messageInfo: section.items[indexPath.row])
            cell.infoLabel.delegate = self
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
         
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        let viewModel = self.viewModels[indexPath.section]
        
        if let viewModel = viewModel as? OrderProductsInfoSection,
            viewModel.isExpandable,
            let _ = viewModel.rows[indexPath.row] as? OrderItem {
            viewModel.isExpanded = !viewModel.isExpanded
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
}

//MARK: MLLinkLabelDelegate
extension CheckOutViewController: MLLinkLabelDelegate {
    func didClick(_ link: MLLink!, linkText: String!, linkLabel: MLLinkLabel!) {
        if let url = URL(string: link.linkValue), url.scheme == self.reloadScheme {
            self.moveToReloadVC()
        }
    }
}

//MARK: OrderOfferTableViewCellDelegate
extension CheckOutViewController: OrderRadioButtonTableViewCellDelegate {
    func orderRadioButtonTableViewCell(cell: OrderRadioButtonTableViewCell, radioButtonTapped sender: UIButton) {
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        guard let viewModel = self.viewModels[indexPath.section] as? OrderOffersSection else {
            return
        }
        
        viewModel.items = viewModel.items.map({ (model) -> OrderDiscount in
            model.isSelected = false
            return model
        })
        
        viewModel.items[indexPath.row].isSelected = true
        
        self.tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.handleRedeemTapped()
        }
    }
}

//MARK: OrderOfferRedeemTableViewCellDelegate
extension CheckOutViewController: OrderOfferRedeemTableViewCellDelegate {
    func orderOfferRedeemTableViewCell(cell: OrderOfferRedeemTableViewCell, redeemButtonTapped sender: UIButton) {
        
        
        
    }
}

//MARK: Webservices Methods
extension CheckOutViewController {
    func getOffers() {
        
        self.isGettingOffers = true
        
        self.offerRequest?.cancel()
        
        let params: [String : Any] = ["establishment_id" : self.order.barId]
        self.offerRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathOrderOffers, method: .get) { (response, serverError, error) in
            
            self.isGettingOffers = false
            self.useCredit = false
            
            defer {
                self.setUpOffersAndVouchers()
            }
            
            guard error == nil else {
                return
            }
            
            guard serverError == nil else {
                
                let msg = serverError!.errorMessages()
                let errorAttributes = [NSAttributedString.Key.foregroundColor : UIColor.red,
                                       NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0)]
                let attributedError = NSMutableAttributedString(string: "\(msg)", attributes: errorAttributes)
                
                
                if let rawError = serverError?.rawResponse,
                    let errs = rawError["errors"] as? [String : Any],
                    let _ = errs["reload"] {
                    
                    let linkAttributes = [NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0),
                                          NSAttributedString.Key.link : URL(string: "\(self.reloadScheme)://")!] as [NSAttributedStringKey : Any]
                    let normalAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                            NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0)]
                    
                    let linkPrefix = NSAttributedString(string: "\nPlease ", attributes: normalAttributes)
                    let link = NSAttributedString(string: "click here", attributes: linkAttributes)
                    let linkSuffix = NSAttributedString(string: " to reload", attributes: normalAttributes)
                    
                    
                    attributedError.append(linkPrefix)
                    attributedError.append(link)
                    attributedError.append(linkSuffix)
                }
                
                self.message = attributedError
                
                return
            }
            
            self.message = nil
    
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseMessage = responseDict?["message"] as? String,
                responseMessage.lowercased() != "success." {
                let normalAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white,
                                        NSAttributedString.Key.font : UIFont.appRegularFontOf(size: 14.0)]
                self.message = NSAttributedString(string: responseMessage, attributes: normalAttributes)
                
                self.useCredit = true
            }
            
            
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                let discounts = Mapper<OrderDiscount>().mapArray(JSONArray: responseArray)
                
                self.offers.removeAll()
                self.offers.append(contentsOf: discounts)

            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
            
        }
    }
    
    func getVouchers() {
        
        //temporarily commented out as per client's request
        return;
        
        self.isGettingVouchers = true
        
        self.voucherRequest?.cancel()
        
        let params: [String : Any] = ["establishment_id" : self.order.barId]
        self.voucherRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathOrderVouchers, method: .get) { (response, serverError, error) in
            
            self.isGettingVouchers = false
            
            defer {
                self.setUpOffersAndVouchers()
            }
            
            guard error == nil else {
                return
            }
            
            guard serverError == nil else {
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                let discounts = Mapper<OrderDiscount>().mapArray(JSONArray: responseArray)
                
                self.vouchers.removeAll()
                self.vouchers.append(contentsOf: discounts)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
            
        }
    }
}

//MARK: Notification Methods
extension CheckOutViewController {
    @objc func reloadSuccessfullNotification(notification: Notification) {
        self.viewModels.removeAll()
        self.tableView.reloadData()
        
        self.offers.removeAll()
        self.vouchers.removeAll()
        
        self.getVouchers()
        self.getOffers()
        
        self.setupViewModel()
    }
}
