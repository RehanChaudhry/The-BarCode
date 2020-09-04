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

class CheckOutViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    @IBOutlet var checkoutButton: UIButton!
    
    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    var viewModels: [OrderViewModel] = []
    
    var order: Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUpStatefulTableView()

        self.closeBarButton.image = self.closeBarButton.image?.withRenderingMode(.alwaysOriginal)
        
        self.setupViewModel()
        
        self.calculateTotal()
    }
    

    //MARK: My Methods
    func setUpStatefulTableView() {
           
        self.statefulTableView.innerTable.register(cellType: OrderInfoTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: OrderStatusTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: OrderRadioButtonTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: OrderOfferRedeemTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: OrderOfferDiscountTableViewCell.self)
        
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
        
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 16))
        tableHeaderView.backgroundColor = UIColor.clear
        self.statefulTableView.innerTable.tableHeaderView = tableHeaderView

    }
    
    func setupViewModel() {
       
        let barInfo = BarInfo(barName: self.order.barName)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)

        let orderProductsSection = OrderProductsInfoSection(items: self.order.orderItems)
        self.viewModels.append(orderProductsSection)
        
        let orderTotalBillInfo = OrderTotalBillInfo(title: "Total", price: 0.0 )
        let orderTotalBillInfoSection = OrderTotalBillInfoSection(items: [orderTotalBillInfo])
        self.viewModels.append(orderTotalBillInfoSection)
        
        let redeemOfferHeading = Heading(title: "Redeem Available Vouchers")
        let redeemOfferHeadingSection = HeadingSection(items: [redeemOfferHeading])
        self.viewModels.append(redeemOfferHeadingSection)
        
        let vouchersSection = OrderOffersSection(type: .vouchers, items: OrderOfferInfo.dummyVouchers())
        self.viewModels.append(vouchersSection)
        
        let standardOfferHeading = Heading(title: "Redeem Available Offers")
        let standardOfferHeadingSection = HeadingSection(items: [standardOfferHeading])
        self.viewModels.append(standardOfferHeadingSection)
        
        let offersSection = OrderOffersSection(type: .offers, items: OrderOfferInfo.dummyOffers())
        self.viewModels.append(offersSection)
        
        let discountInfoSection = OrderOfferDiscountSection(type: .discountInfo, items: [])
        self.viewModels.append(discountInfoSection)
        
        let redeemButton = OrderOfferRedeem(title: "Redeem")
        let offerRedeemSection = OrderOfferRedeemSection(type: .offerRedeem, items: [redeemButton])
        self.viewModels.append(offerRedeemSection)
    }

    func calculateTotal() {
        
        let products = (self.viewModels.first(where: {$0.type == .productDetails}) as? OrderProductsInfoSection)?.items ?? []
        
        var totalProductPrice = products.reduce(0.0) { (total, item) -> Double in
            total + item.unitPrice * Double(item.quantity)
        }
        
        if let totalSectionIndex = self.viewModels.firstIndex(where: {$0.type == .totalBill}) {
            (self.viewModels[totalSectionIndex] as! OrderTotalBillInfoSection).items.first?.price = totalProductPrice
            let indexPath = IndexPath(row: 0, section: totalSectionIndex)
            if self.statefulTableView.innerTable.numberOfSections > 0 {
                self.statefulTableView.innerTable.reloadRows(at: [indexPath], with: .none)
            } else {
                self.statefulTableView.innerTable.reloadData()
            }
        }

        let selectedVoucher = (self.viewModels.first(where: {$0.type == .vouchers}) as? OrderOffersSection)?.items.first(where: {$0.isSelected})
        let selectedOffer = (self.viewModels.first(where: {$0.type == .offers}) as? OrderOffersSection)?.items.first(where: {$0.isSelected})
        
        if let selectedVoucher = selectedVoucher, selectedVoucher.discount > 0 {
            let discountValue = ((totalProductPrice / 100.0) * Double(selectedVoucher.discount))
            totalProductPrice -= discountValue
        }
        
        if let selectedOffer = selectedOffer, selectedOffer.discount > 0 {
            let discountValue = ((totalProductPrice / 100.0) * Double(selectedOffer.discount))
            totalProductPrice -= discountValue
        }
                
        let totalAmount = max(0.0, totalProductPrice)
        self.checkoutButton.setTitle(String(format: "Continue - £ %.2f", totalAmount), for: .normal)
    }
    
    //MARK: My IBActions
    @IBAction func closeBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueButtonTapped(sender: UIButton) {
        
        let discountSection = self.viewModels.first(where: {$0.type == .discountInfo}) as? OrderOfferDiscountSection
        
        var items = discountSection?.items ?? []
        if items.count > 0 {
            items.removeFirst()
        }
        
        
//        let orderTypeController = (self.storyboard!.instantiateViewController(withIdentifier: "OrderTypeViewController") as! OrderTypeViewController)
//        orderTypeController.order = self.order
//        self.navigationController?.pushViewController(orderTypeController, animated: true)
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
            cell.setupCell(orderTotalBillInfo: section.items[indexPath.row], showSeparator: false)
            cell.adjustMargins(adjustTop: isFirstCell, adjustBottom: isLastCell)
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
            
        }
        
        else {
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
        
        viewModel.items = viewModel.items.map({ (model) -> OrderOfferInfo in
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
        
        let isVoucherNoneSelected = vouchers?.items.first?.isSelected == true
        let isOfferNoneSelected = offers?.items.first?.isSelected == true
        
        let total = (self.viewModels.first(where: {$0.type == .totalBill}) as? OrderTotalBillInfoSection)?.items.first?.price ?? 0.0
        
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
                if selectedVoucher.discount > 0.0 {
                    let saving = ((total / 100.0) * Double(selectedVoucher.discount))
                    voucher.value = saving
                }
                
                discountSection.items.append(voucher)
            }
            
            if let selectedOffer = offerItems.first(where: {$0.isSelected}) {
                addHeadingIfNeeded()
                
                let offer = OrderOfferDiscountInfo(title: selectedOffer.text, value: 0.0, isHeading: false)
                if selectedOffer.discount > 0.0 {
                    let saving = ((total / 100.0) * Double(selectedOffer.discount))
                    offer.value = saving
                }
                
                discountSection.items.append(offer)
            }
                        
            let indexSet = IndexSet(integer: index)
            self.statefulTableView.innerTable.reloadSections(indexSet, with: .fade)

        } else {

        }
        
        self.calculateTotal()
    }
}
