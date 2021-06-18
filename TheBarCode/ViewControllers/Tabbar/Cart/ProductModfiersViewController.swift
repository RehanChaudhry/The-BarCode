//
//  ProductModfiersViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/12/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import ObjectMapper
import KVNProgress
import Alamofire
import CoreStore
import KVNProgress

typealias RegionInfo = (country: String, currencySymbol: String, currencyCode: String)

protocol ProductModfiersViewControllerDelegate: AnyObject {
    func productModfiersViewController(controller: ProductModfiersViewController, cartUpdateFailed error: NSError)
}

class ProductModfiersViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    
    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    @IBOutlet var stepperView: StepperView!
    
    @IBOutlet var addToCartButton: GradientButton!
    
    var statefulView: LoadingAndErrorView!
    
    var groups: [ProductModifierGroup] = []
    
    var productInfo: (id: String, name: String, price: Double, quantity: Int)!
    var regionInfo: RegionInfo = ("", "", "")
    
    var cartItemId: String?
    
    var defaultQuantity: Int = 1 // product quantity can be different than order item quantity e.g. same product can be added having multiple modifiers
    
    var establishmentId: String = ""
    var type: String = ""
    
    var headerHeights: [Int : CGFloat] = [:]
    
    var isUpdating: Bool = false
    
    weak var delegate: ProductModfiersViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.closeBarButton.image = self.closeBarButton.image?.withRenderingMode(.alwaysOriginal)
          
        self.titleLabel.text = self.productInfo.name
        self.subTitleLabel.text = self.productInfo.price > 0.0 ? String(format: "\(self.regionInfo.currencySymbol) %.2f", self.productInfo.price) : ""
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(cellType: ProductModifierCell.self)
        self.tableView.register(headerFooterViewType: ProductModifierHeader.self)
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.statefulView.isHidden = true
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self] (sender: UIButton) in
            self.getModifiers()
        }
        
        self.statefulView.autoPinEdgesToSuperviewEdges()
        
        self.stepperView.minValue = 1
        self.stepperView.maxValue = 20
        self.stepperView.value = self.defaultQuantity
        self.stepperView.delegate = self
        
        //if user is coming from cart the modifiers will come from the cart
        self.getModifiers()
        
        self.calculateTotal()
    }
    
    //MARK: My Methods
    /*
    func setupProductPrice() {
        if self.productInfo.price > 0.0 {
            self.subTitleLabel.text = String(format: "£ %.2f", self.productInfo.price)
        } else if self.productInfo.minPrice > 0.0 {
            self.subTitleLabel.text = String(format: "Start Off £ %.2f", self.productInfo.minPrice)
        } else {
            self.subTitleLabel.text = ""
        }
    }
    
    func findMinimumPriceIfNeeded() {
        if self.isUpdating {
            let requiredGroups = self.groups.filter({ $0.isRequired })
            let productModifiers = requiredGroups.reduce([]) { (result, group) -> [ProductModifier] in
                return result + group.modifiers
            }
            
            let minPriceModifier = productModifiers.min(by: { $0.price < $1.price })
                        
            let minPrice = minPriceModifier?.price ?? Double(0.0)
            self.productInfo.minPrice = minPrice
        }
    }*/
    
    @discardableResult func calculateTotal() -> Double {
        let price = self.productInfo.price
        
        let total = self.groups.reduce(0.0) { (total, group) -> Double in
            return total + group.modifiers.reduce(0.0) { (groupTotal, modifier) -> Double in
                return groupTotal + (modifier.isSelected ? modifier.price * Double(modifier.quantity) : 0.0)
            }
        }
        
        let grandTotal = (price * Double(self.stepperView.value)) + (total * Double(self.stepperView.value))
        self.addToCartButton.setTitle(String(format: "Add To Cart - \(self.regionInfo.currencySymbol) %.2f", grandTotal), for: .normal)
        
        return grandTotal
    }
    
    func isDataValid() -> (isValid: Bool, section: Int?) {
        var isValid = true
        var section: Int? = nil
        
        for (groupIndex, group) in self.groups.enumerated() {
            if group.isRequired && group.selectedModifiersQuantity < group.min {
                isValid = false
                section = groupIndex
                self.showAlertController(title: "Required", msg: "Please select atleast \(group.min) from \(group.name)")
                
                break;
            }
        }
        
        return (isValid, section)
    }
    
    //MARK: My IBActions
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addToCartButtonTapped(sender: UIButton) {
        let validationInfo = self.isDataValid()
        if validationInfo.isValid {
            
            guard self.calculateTotal() > 0.0 else {
                KVNProgress.showError(withStatus: "Total price must be greater than 0")
                return
            }
            
            self.updateCart()
        } else if let section = validationInfo.section {
            let indexPath = IndexPath(row: NSNotFound, section: section)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }

}

//MARK: UITableViewDelegate, UITableViewDataSource
extension ProductModfiersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.groups.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups[section].modifiers.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.headerHeights[section] = view.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeights[section] ?? 100.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(ProductModifierHeader.self)
        headerView?.setUpHeader(group: self.groups[section])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let group = self.groups[indexPath.section]
        let item = group.modifiers[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: ProductModifierCell.self)
        cell.setupCell(modifier: item, group: group, regionInfo: self.regionInfo)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

//MARK: ProductModifierCellDelegate
extension ProductModfiersViewController: ProductModifierCellDelegate {
    func productModifierCell(cell: ProductModifierCell, selectionButtonTapped sender: UIButton) {
        
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        defer {
            self.tableView.reloadData()
            self.calculateTotal()
        }
        
        let group = self.groups[indexPath.section]
        let modifier = group.modifiers[indexPath.row]
        
        if modifier.isSelected {
            
            //Restrict user to unselect minimum required items after selection
            if group.selectedModifiersCount > group.min  {
                modifier.isSelected = false
                modifier.quantity = 0
            }
            
            
            
        } else {
            group.unselectAllModifiersForSingleSelection()
            
            if group.max <= 1 || group.selectedModifiersQuantity < group.max {
                modifier.isSelected = true
                modifier.quantity = 1
            }
        }
    }
    
    func productModifierCell(cell: ProductModifierCell, stepperValueChanged stepper: StepperView, value: Int) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        defer {
            self.tableView.reloadData()
            self.calculateTotal()
        }
        
        let group = self.groups[indexPath.section]
        let modifier = group.modifiers[indexPath.row]
        
        let preservedQuantity = modifier.quantity
        
        if (value > 0 || group.selectedModifiersCount > group.min) {
            modifier.quantity = value
        }
        
        if group.selectedModifiersQuantity > group.max {
            modifier.quantity = preservedQuantity
        }
        
        modifier.isSelected = modifier.quantity > 0
    }
}

//MARK: Webservices Methods
extension ProductModfiersViewController {
    func getModifiers() {
        
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        var params: [String : Any] = ["type" : self.type,
                                      "establishment_id" : self.establishmentId,
                                      "product_id" : self.productInfo.id]
        if let cartItemId = self.cartItemId {
            params["cart_item_id"] = cartItemId
        }
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathModifierGroups, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap To refresh")
                return
            }
            
            guard serverError == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To refresh")
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseGroups = (responseDict?["data"] as? [[String : Any]]) {
                self.groups.removeAll()

                self.groups = Mapper<ProductModifierGroup>().mapArray(JSONArray: responseGroups)
                
                self.tableView.reloadData()
                self.calculateTotal()
//                self.findMinimumPriceIfNeeded()
//                self.setupProductPrice()
                
                self.statefulView.isHidden = true
                self.statefulView.showNothing()
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To refresh")
            }
        }
    }
    
    func updateCart() {
        
        let selectedModifier = self.groups.reduce([]) { (groupItems, group) -> [[String : Any]] in
            let selectedModifiers = group.modifiers.filter({$0.isSelected})
            return groupItems + selectedModifiers.map({ ["id" : $0.id , "quantity" : $0.quantity] })
        }
        
        var params: [String : Any] = ["id" : self.productInfo.id,
                                      "quantity" : self.stepperView.value,
                                      "establishment_id" : self.establishmentId,
                                      "modifier_details" : selectedModifier]
        
        if let cartItemId = self.cartItemId {
            params["cart_item_id"] = cartItemId
        }
        
        self.addToCartButton.showLoader()
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathCart, method: .post, encoding: JSONEncoding.default) { (response, serverError, error) in
            
            UIApplication.shared.endIgnoringInteractionEvents()
            
            let product = try! Utility.barCodeDataStack.fetchOne(From<Product>().where(\.id == self.productInfo.id))
            let previousQuantity = self.productInfo.quantity
            
            self.addToCartButton.hideLoader()
            
            defer {
                if self.isUpdating {
                    let object = (itemId: self.productInfo.id,
                                  newQuantity: previousQuantity + (self.stepperView.value - self.defaultQuantity),
                                  oldQuantity: previousQuantity,
                                  barId: self.establishmentId,
                                  controller: self)
                    NotificationCenter.default.post(name: notificationNameMyCartUpdated, object: object, userInfo: nil)
                } else if let product = product {
                    let productCartInfo: ProductCartUpdatedObject = (product: product,
                                                                     newQuantity: self.stepperView.value + previousQuantity,
                                                                     previousQuantity: previousQuantity,
                                                                     barId: self.establishmentId)
                    NotificationCenter.default.post(name: notificationNameProductCartUpdated, object: productCartInfo)
                }
                
            }
            
            guard error == nil else {
                KVNProgress.showError(withStatus: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                if serverError!.detail.count > 0 {
                    KVNProgress.showError(withStatus: serverError!.detail)
                    
                    let needsRefresh = serverError?.rawResponse["refresh"] as? Bool
                    
                    let nsError = NSError(domain: "ServerError", code: serverError!.statusCode, userInfo: [NSLocalizedDescriptionKey : serverError!.detail,
                                                                                                           "refresh" : needsRefresh ?? false])
                    self.delegate?.productModfiersViewController(controller: self, cartUpdateFailed: nsError)
                    
                } else {
                    KVNProgress.showError(withStatus: serverError!.nsError().localizedDescription)
                    self.delegate?.productModfiersViewController(controller: self, cartUpdateFailed: serverError!.nsError())
                }
                return
            }
            
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                if let product = product, let editedProduct = transaction.edit(product) {
                    if self.isUpdating {
                        editedProduct.quantity.value += self.stepperView.value - self.defaultQuantity
                    } else {
                        editedProduct.quantity.value += self.stepperView.value
                    }
                }
            })
            
            self.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: StepperViewDelegate
extension ProductModfiersViewController: StepperViewDelegate {
    func stepperView(stepperView: StepperView, valueChanged value: Int) {
        self.calculateTotal()
    }
}
