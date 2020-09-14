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

class CheckOutViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    @IBOutlet var footerView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var checkoutButton: UIButton!
    
    var viewModels: [OrderViewModel] = []
    
    var vouchers: [OrderDiscount] = []
    var offers: [OrderDiscount] = []
    
    var order: Order!
    
    var totalBillPayable: Double = 0.0
    
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
    
    var message: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        self.setUpStatefulTableView()

        self.getVouchers()
        self.getOffers()
        
        self.setupViewModel()
    }
    
    //MARK: My Methods
    func setUpStatefulTableView() {
           
        self.statefulTableView.innerTable.register(cellType: OrderInfoTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: OrderStatusTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: OrderRadioButtonTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: OrderOfferRedeemTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: OrderOfferDiscountTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: OrderMessageTableViewCell.self)
        
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
        self.statefulTableView.innerTable.tableFooterView = self.footerView
        
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 16))
        tableHeaderView.backgroundColor = UIColor.clear
        self.statefulTableView.innerTable.tableHeaderView = tableHeaderView

    }
    
    func setupViewModel() {
        
        self.viewModels.removeAll()
        let barInfo = BarInfo(barName: self.order.barName)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)

        let orderProductsSection = OrderProductsInfoSection(items: self.order.orderItems)
        self.viewModels.append(orderProductsSection)
        
        if self.order.orderType == .delivery {
            let deliveryCharges = Utility.shared.getDeliveryCharges(order: self.order, totalPrice: self.getProductsTotalPrice())
            
            let orderDeliveryInfo = OrderDeliveryInfo(title: "Delivery Charges", price: deliveryCharges)
            let orderDeliveryInfoSection = OrderDeliveryInfoSection(items: [orderDeliveryInfo])
            self.viewModels.append(orderDeliveryInfoSection)
        }
        
        let orderTotalBillInfo = OrderBillInfo(title: self.order.splitPaymentInfo == nil ? "Total" : "Grand Total", price: 0.0)
        let orderTotalBillInfoSection = OrderTotalBillInfoSection(items: [orderTotalBillInfo])
        self.viewModels.append(orderTotalBillInfoSection)
        
        if let splitInfo = self.order.splitPaymentInfo {
            let splitAmountInfo = OrderBillInfo(title: "Split Amount", price: splitInfo.value)
            let splitTotalInfo = OrderBillInfo(title: "Total", price: splitInfo.value)
            let orderSplitBillInfoSection = OrderSplitAmountInfoSection(items: [splitAmountInfo, splitTotalInfo])
            self.viewModels.append(orderSplitBillInfoSection)
        }
        
        if !self.isGettingOffers && !self.isGettingVouchers {
            let redeemOfferHeading = Heading(title: "Redeem Available Vouchers")
            let redeemOfferHeadingSection = HeadingSection(items: [redeemOfferHeading])
            self.viewModels.append(redeemOfferHeadingSection)
            
            let voucherNone = OrderDiscount(JSON: ["id" : 0])!
            voucherNone.text = "None"
            voucherNone.isSelected = true
            
            self.vouchers = self.vouchers.map({ (discount) -> OrderDiscount in
                discount.isSelected = false
                return discount
            })
            
            let vouchersSection = OrderOffersSection(type: .vouchers, items: [voucherNone] + self.vouchers)
            self.viewModels.append(vouchersSection)
            
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
            
            let redeemButton = OrderOfferRedeem(title: "Redeem", enable: (self.offers.count > 0 && self.vouchers.count > 0))
            let offerRedeemSection = OrderOfferRedeemSection(type: .offerRedeem, items: [redeemButton])
            self.viewModels.append(offerRedeemSection)
        }
    
        self.statefulTableView.innerTable.reloadData()
        self.calculateTotal()
    }

    func getProductsTotalPrice() -> Double {
        
        let total: Double = self.order.orderItems.reduce(0.0) { (result, item) -> Double in
            return result + (Double(item.quantity) * item.unitPrice)
        }

        return total
    }
    
    func calculateTotal() {
        
        var totalProductPrice = self.getProductsTotalPrice()
        
        let selectedVoucher = (self.viewModels.first(where: {$0.type == .vouchers}) as? OrderOffersSection)?.items.first(where: {$0.isSelected})
        let selectedOffer = (self.viewModels.first(where: {$0.type == .offers}) as? OrderOffersSection)?.items.first(where: {$0.isSelected})
        
        var voucherDiscount: Double = 0.0
        if let selectedVoucher = selectedVoucher, selectedVoucher.value > 0.0 {
            
            let discountableAmount = self.order.splitPaymentInfo?.value ?? totalProductPrice
            if selectedVoucher.valueType == .percent {
                voucherDiscount = ((min(20.0, discountableAmount) / 100.0) * selectedVoucher.value)
            } else if selectedVoucher.valueType == .amount {
                voucherDiscount = selectedVoucher.value
            }
        }
        
        var offerDiscount: Double = 0.0
        if let selectedOffer = selectedOffer, selectedOffer.value > 0 {
            
            let discountableAmount = self.order.splitPaymentInfo?.value ?? totalProductPrice
            if selectedOffer.valueType == .percent {
                offerDiscount = ((min(20.0, discountableAmount) / 100.0) * selectedOffer.value)
            } else if selectedOffer.valueType == .amount {
                offerDiscount = selectedOffer.value
            }
        }
        
        if self.order.splitPaymentInfo == nil {
            totalProductPrice -= voucherDiscount
            totalProductPrice -= offerDiscount
        }
        
        if let deliverySection = self.viewModels.first(where: {$0.type == .deliveryChargesDetails}) as? OrderDeliveryInfoSection,
            let deliveryItem = deliverySection.items.first {
            totalProductPrice += deliveryItem.price
        }
        
        totalProductPrice = max(0, totalProductPrice)
        
        if let totalSectionIndex = self.viewModels.firstIndex(where: {$0.type == .totalBill}) {
            (self.viewModels[totalSectionIndex] as! OrderTotalBillInfoSection).items.first?.price = totalProductPrice
            let indexPath = IndexPath(row: 0, section: totalSectionIndex)
            
            if self.statefulTableView.innerTable.numberOfSections > 0 {
                UIView.performWithoutAnimation {
                    self.statefulTableView.innerTable.reloadRows(at: [indexPath], with: .none)
                }
            } else {
                self.statefulTableView.innerTable.reloadData()
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
            
            totalProductPrice -= paidAmount
            self.totalBillPayable = max(0.0, totalProductPrice)
        }
        
        self.checkoutButton.setTitle(String(format: "Continue - £ %.2f", self.totalBillPayable), for: .normal)
        
    }
    
    func updateLoader() {
        if self.isGettingVouchers || self.isGettingOffers {
            self.activityIndicator.startAnimating()
        } else {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func setUpOffersAndVouchers() {
        if !self.isGettingOffers && !self.isGettingVouchers {
            self.setupViewModel()
        }
    }
    
    //MARK: My IBActions
    
    @IBAction func continueButtonTapped(sender: UIButton) {
        
        var voucherItems: [OrderDiscount] = []
        voucherItems.append(contentsOf: (self.viewModels.first(where: {$0.type == .vouchers}) as? OrderOffersSection)?.items ?? [])
        voucherItems.removeFirst()
        
        var offerItems: [OrderDiscount] = []
        offerItems.append(contentsOf: (self.viewModels.first(where: {$0.type == .offers}) as? OrderOffersSection)?.items ?? [])
        offerItems.removeFirst()
        
        let selectedVoucher = voucherItems.first(where: {$0.isSelected})
        let selectedOffer = offerItems.first(where: {$0.isSelected})
            
        let paymentController = (self.storyboard!.instantiateViewController(withIdentifier: "SavedCardsViewController") as! SavedCardsViewController)
        paymentController.order = self.order
        paymentController.totalBillPayable = self.totalBillPayable
        paymentController.selectedVoucher = selectedVoucher
        paymentController.selectedOffer = selectedOffer
        self.navigationController?.pushViewController(paymentController, animated: true)
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension CheckOutViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        
        if let section = viewModel as? BarInfoSection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(barInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
        
        } else if let section = viewModel as? OrderProductsInfoSection {
     
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderItem: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell

        } else if let section = viewModel as? OrderTotalBillInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            
            let cornerRadius: CGFloat = self.order.splitPaymentInfo == nil ? 8.0 : 0.0
            cell.setupCell(orderTotalBillInfo: section.items[indexPath.row], showSeparator: self.order.splitPaymentInfo == nil ? false : true, radius: cornerRadius)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            
            return cell
            
        } else if let section = viewModel as? OrderSplitAmountInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            
            let cornerRadius: CGFloat = isLastCell ? 8.0 : 0.0
            cell.setupCell(orderTotalBillInfo: section.items[indexPath.row], showSeparator: !isLastCell, radius: cornerRadius)
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
            cell.setupCell(orderOfferInfo: section.items[indexPath.row], showSeparator: (isLastCell && section.type == .vouchers))
            cell.delegate = self
            return cell
            
        } else if let section = viewModel as? OrderOfferRedeemSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderOfferRedeemTableViewCell.self)
            cell.setUpCell(orderOfferRedeem: section.items[indexPath.row])
            cell.delegate = self
            return cell
            
        } else if let section = viewModel as? OrderOfferDiscountSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderOfferDiscountTableViewCell.self)
            cell.setUpCell(discountInfo: section.items[indexPath.row], isFirst: isFirstCell, isLast: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderDeliveryInfoSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDeliveryInfo: section.items[indexPath.row], showSeparator: isLastCell)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
            return cell
            
        } else if let section = viewModel as? OrderMessageSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderMessageTableViewCell.self)
            cell.setUpCell(messageInfo: section.items[indexPath.row])
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
         
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
    }
}

//MARK: OrderOfferTableViewCellDelegate
extension CheckOutViewController: OrderRadioButtonTableViewCellDelegate {
    func orderRadioButtonTableViewCell(cell: OrderRadioButtonTableViewCell, radioButtonTapped sender: UIButton) {
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
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
        
        self.statefulTableView.innerTable.reloadData()
    }
}

//MARK: OrderOfferRedeemTableViewCellDelegate
extension CheckOutViewController: OrderOfferRedeemTableViewCellDelegate {
    func orderOfferRedeemTableViewCell(cell: OrderOfferRedeemTableViewCell, redeemButtonTapped sender: UIButton) {
        
        let vouchers = self.viewModels.first(where: {$0.type == .vouchers}) as? OrderOffersSection
        let offers = self.viewModels.first(where: {$0.type == .offers}) as? OrderOffersSection
    
        let total = self.order.splitPaymentInfo?.value ?? self.getProductsTotalPrice()
        
        if let index = self.viewModels.firstIndex(where: {$0.type == .discountInfo}) {
            
            let discountSection = self.viewModels[index] as! OrderOfferDiscountSection
            discountSection.items.removeAll()
            
            var voucherItems = vouchers?.items ?? []
            voucherItems.removeFirst()
            
            var offerItems = offers?.items ?? []
            offerItems.removeFirst()
            
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
            }
            
            if let selectedOffer = offerItems.first(where: {$0.isSelected}) {
                addHeadingIfNeeded()
                
                let offer = OrderOfferDiscountInfo(title: selectedOffer.text, value: 0.0, isHeading: false)
                if selectedOffer.valueType == .percent {
                    let saving = ((min(20, total) / 100.0) * selectedOffer.value)
                    offer.value = saving
                } else if selectedOffer.valueType == .amount {
                    let saving = selectedOffer.value
                    offer.value = saving
                }
                
                discountSection.items.append(offer)
            }
                        
            let indexSet = IndexSet(integer: index)
            self.statefulTableView.innerTable.reloadSections(indexSet, with: .fade)

        } else {

        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [unowned self] in
            self.calculateTotal()
        }
        
    }
}

//MARK: Webservices Methods
extension CheckOutViewController {
    func getOffers() {
        
        self.isGettingOffers = true
        
        let params: [String : Any] = ["establishment_id" : self.order.barId]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathOrderOffers, method: .get) { (response, serverError, error) in
            
            self.isGettingOffers = false
            
            defer {
                self.setUpOffersAndVouchers()
            }
            
            guard error == nil else {
                return
            }
            
            guard serverError == nil else {
                self.message = serverError!.errorMessages()
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
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
        
        self.isGettingVouchers = true
        
        let params: [String : Any] = ["establishment_id" : self.order.barId]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathOrderVouchers, method: .get) { (response, serverError, error) in
            
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
