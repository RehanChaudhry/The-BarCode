//
//  OrderTypeViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 05/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import Alamofire
import ObjectMapper

class OrderTypeViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var checkoutButton: GradientButton!
    
    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    var viewModels: [OrderViewModel] = []
    
    var order: Order!
        
    var totalBillPayable: Double = 0.0
    
    var selectedAddress: Address?
    
    var addressRequest: DataRequest?
    
    var isLoadingAddress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Order Type"
        
        self.closeBarButton.image = self.closeBarButton.image?.withRenderingMode(.alwaysOriginal)
        
        self.setUpStatefulTableView()
        
        self.setupViewModel()
        self.calculateTotal()
        
        if self.order.isDeliveryAvailable {
            self.getAddress()
        }
    }


    //MARK: My Methods
    func setUpStatefulTableView() {
           
        self.tableView.register(cellType: OrderInfoTableViewCell.self)
        self.tableView.register(cellType: OrderStatusTableViewCell.self)
        self.tableView.register(cellType: OrderRadioButtonTableViewCell.self)
        self.tableView.register(cellType: OrderDineInFieldTableViewCell.self)
        self.tableView.register(cellType: OrderDeliveryAddressTableViewCell.self)
        
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 16))
        tableHeaderView.backgroundColor = UIColor.clear
        self.tableView.tableHeaderView = tableHeaderView
        self.tableView.tableFooterView = UIView()
    }
    
    func setupViewModel() {
       
        let barInfo = BarInfo(barName: self.order.barName)
        let barInfoSection = BarInfoSection(items: [barInfo])
        self.viewModels.append(barInfoSection)

        let orderProductsSection = OrderProductsInfoSection(items: self.order.orderItems)
        self.viewModels.append(orderProductsSection)
        
        let orderTotalBillInfo = OrderTotalBillInfo(title: "Total", price: 0.0)
        let orderTotalBillInfoSection = OrderTotalBillInfoSection(items: [orderTotalBillInfo])
        self.viewModels.append(orderTotalBillInfoSection)
        
        let standardOfferHeading = Heading(title: "Select Order Type")
        let standardOfferHeadingSection = HeadingSection(items: [standardOfferHeading])
        self.viewModels.append(standardOfferHeadingSection)
        
        let dineRadioButton = OrderRadioButton(title: "Dine In", subTitle: "")
        dineRadioButton.isSelected = true
        let dineInSection = OrderDineInSection(items: [dineRadioButton])
        self.viewModels.append(dineInSection)
        
        let dineInField = OrderDineInField()
        let dineInFieldSection = OrderDineInFieldSection(items: [dineInField])
        self.viewModels.append(dineInFieldSection)
        
        let counterRadioButton = OrderRadioButton(title: "Counter Collection", subTitle: "")
        let counterCollectionSection = OrderCounterCollectionSection(items: [counterRadioButton])
        self.viewModels.append(counterCollectionSection)
        
        let takeAwayRadio = OrderRadioButton(title: "Takeaway", subTitle: "")
        let takeAwaySection = OrderTakeAwaySection(items: [takeAwayRadio])
        self.viewModels.append(takeAwaySection)
        
        if self.order.isDeliveryAvailable {
            let deliveryRadioButton = OrderRadioButton(title: "Delivery", subTitle: "")
            deliveryRadioButton.value = self.getDeliveryCharges()
            deliveryRadioButton.isEnabled = !self.order.isCurrentlyDeliveryDisabled
            
            let deliverySection = OrderDeliverySection(items: [deliveryRadioButton])
            self.viewModels.append(deliverySection)
            
            let deliveryAddressSection = OrderDeliveryAddressSection(items: [])
            self.viewModels.append(deliveryAddressSection)
        }
    }
    
    func getProductsTotalPrice() -> Double {
        let products = (self.viewModels.first(where: {$0.type == .productDetails}) as? OrderProductsInfoSection)?.items ?? []
        
        let totalProductPrice = products.reduce(0.0) { (total, item) -> Double in
            total + item.unitPrice * Double(item.quantity)
        }
        
        if let totalSectionIndex = self.viewModels.firstIndex(where: {$0.type == .totalBill}) {
            (self.viewModels[totalSectionIndex] as! OrderTotalBillInfoSection).items.first?.price = totalProductPrice
            let indexPath = IndexPath(row: 0, section: totalSectionIndex)
            if self.tableView.numberOfSections > 0 {
                self.tableView.reloadRows(at: [indexPath], with: .none)
            } else {
                self.tableView.reloadData()
            }
        }
        
        return totalProductPrice
    }
    
    func calculateTotal() {
        
        var totalProductPrice = self.getProductsTotalPrice()

        if let deliverySection = self.viewModels.first(where: {$0.type == .delivery}) as? OrderDeliverySection,
            let deliveryItem = deliverySection.items.first,
            deliveryItem.isSelected {
            totalProductPrice += deliveryItem.value
        }
        
        let totalAmount = max(0.0, totalProductPrice)
        self.totalBillPayable = totalAmount
        self.checkoutButton.setTitle(String(format: "Continue - £ %.2f", totalAmount), for: .normal)
    }
    
    func unSelectAllOrderTypeRadios() {
        (self.viewModels.first(where: {$0.type == .dineIn}) as? OrderDineInSection)?.items.first?.isSelected = false
        (self.viewModels.first(where: {$0.type == .takeAway}) as? OrderTakeAwaySection)?.items.first?.isSelected = false
        (self.viewModels.first(where: {$0.type == .counterCollection}) as? OrderCounterCollectionSection)?.items.first?.isSelected = false
        (self.viewModels.first(where: {$0.type == .delivery}) as? OrderDeliverySection)?.items.first?.isSelected = false
    }
    
    func reloadOrderTypeSections() {
        let dineInSectionIndex = self.viewModels.firstIndex(where: {$0.type == .dineIn}) ?? 0
        let indexSet = IndexSet(integersIn: dineInSectionIndex..<self.viewModels.count)
        self.tableView.reloadSections(indexSet, with: .fade)
    }
    
    func addDineInField() {
        if let sectionIndex = self.viewModels.firstIndex(where: {$0.type == .tableNo}),
            let section = self.viewModels[sectionIndex] as? OrderDineInFieldSection,
            section.items.count == 0 {
            let field = OrderDineInField()
            section.items.append(field)
        }
    }
    
    func removeDineInField() {
        if let sectionIndex = self.viewModels.firstIndex(where: {$0.type == .tableNo}),
            let fieldSection = self.viewModels[sectionIndex] as? OrderDineInFieldSection {
            fieldSection.items.removeAll()
        }
    }
    
    func addAddress() {
        if let sectionIndex = self.viewModels.firstIndex(where: {$0.type == .deliveryAddress}),
            let section = self.viewModels[sectionIndex] as? OrderDeliveryAddressSection,
            section.items.count == 0 {
            let field = OrderDeliveryAddress()
            field.address = self.selectedAddress
            field.isLoading = self.isLoadingAddress

            section.items.append(field)
            
            self.setUpDeliveryCharges()
        }
    }
    
    func getDeliveryCharges() -> Double {
        if self.order.isGlobalDeliveryAllowed == true {
            return self.order.globalDeliveryCharges ?? 0.0
        } else {
            let total: Double = self.getProductsTotalPrice()
            if let customDeliveryCharges = self.order.customDeliveryCharges, total > customDeliveryCharges {
                return self.order.minDeliveryCharges ?? 0.0
            } else {
                return self.order.maxDeliveryCharges ?? 0.0
            }
        }
    }
    
    func setUpDeliveryCharges() {
        if let deliverySection = self.viewModels.first(where: {$0.type == .delivery}) as? OrderDeliverySection,
            let deliveryItem = deliverySection.items.first {
            if deliveryItem.isSelected {
                deliveryItem.value = self.getDeliveryCharges()
            } else {
                deliveryItem.value = 0.0
            }
        }
    }
    
    func removeAddress() {
        if let sectionIndex = self.viewModels.firstIndex(where: {$0.type == .deliveryAddress}),
            let fieldSection = self.viewModels[sectionIndex] as? OrderDeliveryAddressSection {
            fieldSection.items.removeAll()
        }
    }
    
    func setUpDeliveryAddress(address: Address?) {
        
        self.selectedAddress = address
        
        if let addressSection = self.viewModels.first(where: {$0.type == .deliveryAddress}) as? OrderDeliveryAddressSection,
            let addressInfo = addressSection.items.first {
    
            addressInfo.address = address
            addressInfo.isLoading = false

            self.tableView.reloadData()
        }
    }
    
    func moveToPaymentMethods(viewModels: [OrderViewModel]) {
        let controller = (self.storyboard!.instantiateViewController(withIdentifier: "SavedCardsViewController") as! SavedCardsViewController)
        controller.totalBillPayable = self.totalBillPayable
        controller.viewModels = viewModels
        controller.order = self.order
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func moveToSplitPayment() {
        var viewModels: [OrderViewModel] = []
        if let index = self.viewModels.firstIndex(where: {$0.type == .totalBill}) {
            viewModels = self.viewModels[0...index].map({$0})
        }
        
        let splitpaymentController = self.storyboard!.instantiateViewController(withIdentifier: "SplitPaymentInfoViewController") as! SplitPaymentInfoViewController
        splitpaymentController.order = self.order
        splitpaymentController.viewModels = viewModels
        splitpaymentController.totalBillPayable = self.totalBillPayable
        self.navigationController?.pushViewController(splitpaymentController, animated: true)
    }
    
    //MARK: My IBActions
    @IBAction func closeBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueButtonTapped(sender: UIButton) {
        
        self.createOrder()
        
        if let section = self.viewModels.first(where: {$0.type == .dineIn}) as? OrderDineInSection,
            section.items.first?.isSelected == true {
            self.moveToSplitPayment()
        } else if let section = self.viewModels.first(where: {$0.type == .delivery}) as? OrderDeliverySection,
            section.items.first?.isSelected == true {
            var viewModels: [OrderViewModel] = []
            if let index = self.viewModels.firstIndex(where: {$0.type == .totalBill}) {
                viewModels = self.viewModels[0...index].map({$0})
                
                let deliveryCharges = section.items.first?.value ?? 0.0
                
                let orderDeliveryInfo = OrderDeliveryInfo(title: "Delivery Charges", price: deliveryCharges)
                let orderDeliveryInfoSection = OrderDeliveryInfoSection(items: [orderDeliveryInfo])
                viewModels.insert(orderDeliveryInfoSection, at: index)
            }

            self.moveToPaymentMethods(viewModels: viewModels)
        } else {
            var viewModels: [OrderViewModel] = []
            if let index = self.viewModels.firstIndex(where: {$0.type == .totalBill}) {
                viewModels = self.viewModels[0...index].map({$0})
            }
            self.moveToPaymentMethods(viewModels: viewModels)
        }
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension OrderTypeViewController: UITableViewDataSource, UITableViewDelegate {
    
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

        } else if let section = viewModel as? OrderDiscountSection {
            
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderInfoTableViewCell.self)
            cell.setupCell(orderDiscountInfo: section.items[indexPath.row], showSeparator: isLastCell)
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
            
        } else if let section = viewModel as? OrderDineInSection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderRadioButtonTableViewCell.self)
            cell.delegate = self
            cell.setUpCell(radioButton: section.items[indexPath.row])
            return cell
        } else if let section = viewModel as? OrderCounterCollectionSection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderRadioButtonTableViewCell.self)
            cell.delegate = self
            cell.setUpCell(radioButton: section.items[indexPath.row])
            return cell
        } else if let section = viewModel as? OrderTakeAwaySection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderRadioButtonTableViewCell.self)
            cell.delegate = self
            cell.setUpCell(radioButton: section.items[indexPath.row])
            return cell
        } else if let section = viewModel as? OrderDeliverySection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderRadioButtonTableViewCell.self)
            cell.delegate = self
            cell.setUpCell(radioButton: section.items[indexPath.row])
            return cell
        } else if let section = viewModel as? OrderDineInFieldSection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderDineInFieldTableViewCell.self)
            cell.setUpCell(orderField: section.items[indexPath.row])
            return cell
        } else if let section = viewModel as? OrderDeliveryAddressSection {
            let cell = tableView.dequeueReusableCell(for: indexPath, cellType: OrderDeliveryAddressTableViewCell.self)
            cell.setupCell(address: section.items[indexPath.row])
            return cell
        } else {
            
            return UITableViewCell()
        
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        if let _ = self.viewModels[indexPath.section] as? OrderDeliveryAddressSection {
            let addressController = (self.storyboard!.instantiateViewController(withIdentifier: "AddressesViewController") as! AddressesViewController)
            addressController.isSelectingAddress = true
            addressController.shouldShowCrossIcon = false
            addressController.delegate = self
            self.navigationController?.pushViewController(addressController, animated: true)
        }
    }
}

//MARK: AddressesViewControllerDelegate
extension OrderTypeViewController: AddressesViewControllerDelegate {
    func addressesViewController(controller: AddressesViewController, didSelectAddress address: Address) {
        
        self.addressRequest?.cancel()
        self.isLoadingAddress = false
        
        self.setUpDeliveryAddress(address: address)
    }
}

//MARK: OrderRadioButtonTableViewCellDelegate
extension OrderTypeViewController: OrderRadioButtonTableViewCellDelegate {
    func orderRadioButtonTableViewCell(cell: OrderRadioButtonTableViewCell, radioButtonTapped sender: UIButton) {
        self.unSelectAllOrderTypeRadios()
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        if let dineIn = self.viewModels[indexPath.section] as? OrderDineInSection {
            dineIn.items.first?.isSelected = true
            
            self.addDineInField()
            self.removeAddress()
            
        } else if let takeAway = self.viewModels[indexPath.section] as? OrderTakeAwaySection {
            takeAway.items.first?.isSelected = true
            
            self.removeDineInField()
            self.removeAddress()
            
        } else if let counterCollection  = self.viewModels[indexPath.section] as? OrderCounterCollectionSection {
            counterCollection.items.first?.isSelected = true
            
            self.removeDineInField()
            self.removeAddress()
        } else if let deliverySetion = self.viewModels[indexPath.section] as? OrderDeliverySection {
            deliverySetion.items.first?.isSelected = true
            
            self.removeDineInField()
            self.addAddress()
        }
        
        self.reloadOrderTypeSections()
        self.calculateTotal()
    }
}

//MARK: Webservices Methods
extension OrderTypeViewController {
    func getAddress() {
        let params: [String : Any] = ["pagination" : true,
                                      "limit" : 1,
                                      "page": 1]
        
        self.isLoadingAddress = true
        self.addressRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathAddresses, method: .get, completion: { (response, serverError, error) in
            
            self.isLoadingAddress = false
            
            defer {
                self.setUpDeliveryAddress(address: self.selectedAddress)
            }
            
            guard error == nil else {
                return
            }
            
            guard serverError == nil else {
                return
            }
            
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                let addresses = Mapper<Address>().mapArray(JSONArray: responseArray)
                self.selectedAddress = addresses.first
            }
            
        })
    }
    
    func createOrder() {
        self.checkoutButton.isUserInteractionEnabled = false
        self.checkoutButton.showLoader()
        
        let params: [String : Any] = [:]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathOrders, method: .post) { (response, serverError, error) in
            
            self.checkoutButton.isUserInteractionEnabled = true
            self.checkoutButton.hideLoader()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError!.detail)
                return
            }
            
            
            
        }
    }
}
