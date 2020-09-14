//
//  SplitPaymentViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 08/09/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit

enum SplitPaymentType: String {
    case equal = "equal", fixed = "fixed", percent = "percent", none = "none"
}

typealias SplitPaymentInfo = (type: SplitPaymentType, value: Double)

class SplitBillViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var viewModels: [OrderViewModel] = []
    
    var order: Order!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Split The Bill"
        
        self.addBackButton()
        
        self.tableView.register(cellType: OrderInfoTableViewCell.self)
        self.tableView.register(cellType: OrderStatusTableViewCell.self)
        self.tableView.register(cellType: OrderPaymentTableViewCell.self)
        self.tableView.register(cellType: OrderRadioButtonTableViewCell.self)
        self.tableView.register(cellType: OrderDineInFieldTableViewCell.self)
        
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 16))
        tableHeaderView.backgroundColor = UIColor.clear
        self.tableView.tableHeaderView = tableHeaderView
        self.tableView.tableFooterView = UIView()
        
        self.setupViewModel()
    }
    
    //MARK: My Methods
    func getProductsTotal() -> Double {
        return order.orderItems.reduce(0.0) { (result, item) -> Double in
            return result + (Double(item.quantity) * item.unitPrice)
        }
    }
    
    func setupViewModel() {
        
        self.viewModels.removeAll()
        
        let barInfo = BarInfo(barName: order.barName)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)

        let orderProductsSection = OrderProductsInfoSection(items: order.orderItems)
        self.viewModels.append(orderProductsSection)
        
        let total: Double = self.getProductsTotal()
        
        let orderTotalBillInfo = OrderBillInfo(title: "Grand Total", price: total)
        let orderTotalBillInfoSection = OrderTotalBillInfoSection(items: [orderTotalBillInfo])
        self.viewModels.append(orderTotalBillInfoSection)
        
        let standardOfferHeading = Heading(title: "How you would like to spit?")
        let standardOfferHeadingSection = HeadingSection(items: [standardOfferHeading])
        self.viewModels.append(standardOfferHeadingSection)
        
        let equalSplitRadioButton = OrderRadioButton(title: "50 - 50 Equal Split", subTitle: "")
        equalSplitRadioButton.isSelected = true
        let equalSplitSection = OrderSplitBillTypeSection(items: [equalSplitRadioButton], type: .equalSplit)
        self.viewModels.append(equalSplitSection)
        
        let fixedSplitRadioButton = OrderRadioButton(title: "Split by fixed amount", subTitle: "")
        let fixedSplitSection = OrderSplitBillTypeSection(items: [fixedSplitRadioButton], type: .fixedAmountSplit)
        self.viewModels.append(fixedSplitSection)
        
        let fixedAmountFieldSection = OrderFieldSection(items: [], type: .fixedAmountSplitField)
        self.viewModels.append(fixedAmountFieldSection)
        
        let percentSplitRadioButton = OrderRadioButton(title: "Split by percentage (%)", subTitle: "")
        let percentSplitSection = OrderSplitBillTypeSection(items: [percentSplitRadioButton], type: .percentSplit)
        self.viewModels.append(percentSplitSection)
        
        let percentSplitFieldSection = OrderFieldSection(items: [], type: .percentSplitField)
        self.viewModels.append(percentSplitFieldSection)
        
        self.tableView.reloadData()
    }
    
    func unSelectAllSplitTypeRadios() {
        (self.viewModels.first(where: {$0.type == .equalSplit}) as? OrderSplitBillTypeSection)?.items.first?.isSelected = false
        (self.viewModels.first(where: {$0.type == .fixedAmountSplit}) as? OrderSplitBillTypeSection)?.items.first?.isSelected = false
        (self.viewModels.first(where: {$0.type == .percentSplit}) as? OrderSplitBillTypeSection)?.items.first?.isSelected = false
    }
    
    func addField(type: OrderSectionType) {
        if let sectionIndex = self.viewModels.firstIndex(where: {$0.type == type}),
            let section = self.viewModels[sectionIndex] as? OrderFieldSection,
            section.items.count == 0 {
            let field = OrderFieldInput()
            field.allowedCharacterSet = CharacterSet.init(charactersIn: "1234567890.")
            field.keyboardType = .decimalPad
            
            if section.type == .fixedAmountSplitField {
                field.placeholder = "Enter amount"
            } else if section.type == .percentSplitField {
                field.placeholder = "Enter percentage (%)"
            }
            
            section.items.append(field)
        }
    }
    
    func removeField(type: OrderSectionType) {
        if let sectionIndex = self.viewModels.firstIndex(where: {$0.type == type}),
            let fieldSection = self.viewModels[sectionIndex] as? OrderFieldSection {
            fieldSection.items.removeAll()
        }
    }
    
    func reloadSplitTypeSections() {
        let sectionIndex = self.viewModels.firstIndex(where: {$0.type == .equalSplit}) ?? 0
        let indexSet = IndexSet(integersIn: sectionIndex..<self.viewModels.count)
        self.tableView.reloadSections(indexSet, with: .fade)
    }
    
    func getSplitInfo() -> (splitInfo: SplitPaymentInfo, isValid: Bool) {
        var isValid: Bool = true
        var splitPaymentInfo: SplitPaymentInfo = (type: .equal, value: 0.0)
        
        if (self.viewModels.first(where: {$0.type == .equalSplit}) as? OrderSplitBillTypeSection)?.items.first?.isSelected == true {
            splitPaymentInfo = (type: .equal, value: self.getProductsTotal() / 2.0)
        } else if (self.viewModels.first(where: {$0.type == .fixedAmountSplit}) as? OrderSplitBillTypeSection)?.items.first?.isSelected == true {

            let value = (self.viewModels.first(where: {$0.type == .fixedAmountSplitField}) as? OrderFieldSection)?.items.first?.text ?? ""
            if let amount = Double(value), amount <= self.getProductsTotal(), amount > 0 {
                splitPaymentInfo = (type: .fixed, value: amount)
            } else {
                isValid = false
                self.showAlertController(title: "", msg: "Please enter a valid amount")
            }
            
        } else if (self.viewModels.first(where: {$0.type == .percentSplit}) as? OrderSplitBillTypeSection)?.items.first?.isSelected == true {
            
            let value = (self.viewModels.first(where: {$0.type == .percentSplitField}) as? OrderFieldSection)?.items.first?.text ?? ""
            if let percent = Double(value), percent <= 100.0, percent > 0 {
                splitPaymentInfo = (type: .percent, value: percent / self.getProductsTotal() * 100.0)
            } else {
                isValid = false
                self.showAlertController(title: "", msg: "Please enter a valid percentage")
            }
        }
        
        return (splitPaymentInfo, isValid)
    }
    
    //MARK: My IBActions
    @IBAction func continueButtonTapped(sender: UIButton) {

        let info = self.getSplitInfo()
        
        if info.isValid {
            self.order.splitPaymentInfo = info.splitInfo
            
            let controller = (self.storyboard!.instantiateViewController(withIdentifier: "CheckOutViewController") as! CheckOutViewController)
            controller.order = self.order
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension SplitBillViewController: UITableViewDataSource, UITableViewDelegate {
    
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
            
        } else if let section = viewModel as? OrderSplitBillTypeSection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderRadioButtonTableViewCell.self)
            cell.delegate = self
            cell.setUpCell(radioButton: section.items[indexPath.row])
            return cell
        } else if let section = viewModel as? OrderFieldSection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderDineInFieldTableViewCell.self)
            cell.setUpCell(orderField: section.items[indexPath.row])
            return cell
        } else {
            
            return UITableViewCell()
        
        }
    }
         
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
    }
}

//MARK: OrderRadioButtonTableViewCellDelegate
extension SplitBillViewController: OrderRadioButtonTableViewCellDelegate {
    func orderRadioButtonTableViewCell(cell: OrderRadioButtonTableViewCell, radioButtonTapped sender: UIButton) {
        
        self.unSelectAllSplitTypeRadios()
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        if let equalSplit = self.viewModels[indexPath.section] as? OrderSplitBillTypeSection, equalSplit.type == .equalSplit {
            
            equalSplit.items.first?.isSelected = true
            
            self.removeField(type: .fixedAmountSplitField)
            self.removeField(type: .percentSplitField)
            
        } else if let fixedSplit = self.viewModels[indexPath.section] as? OrderSplitBillTypeSection, fixedSplit.type == .fixedAmountSplit {
            
            fixedSplit.items.first?.isSelected = true
            
            self.addField(type: .fixedAmountSplitField)
            self.removeField(type: .percentSplitField)
            
        } else if let percentSplit = self.viewModels[indexPath.section] as? OrderSplitBillTypeSection, percentSplit.type == .percentSplit {
            
            percentSplit.items.first?.isSelected = true
            
            self.addField(type: .percentSplitField)
            self.removeField(type: .fixedAmountSplitField)
        }
        
        self.reloadSplitTypeSections()
    }
}
