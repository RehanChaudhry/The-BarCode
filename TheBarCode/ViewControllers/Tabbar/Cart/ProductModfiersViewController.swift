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

class ProductModfiersViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    
    @IBOutlet var closeBarButton: UIBarButtonItem!
    
    @IBOutlet var stepperView: StepperView!
    
    @IBOutlet var addToCartButton: GradientButton!
    
    var statefulView: LoadingAndErrorView!
    
    var groups: [ProductModifierGroup] = []
    
    var productId: String = ""
    var price: Double = 0.0
    var productName: String = ""
    var establishmentId: String = ""
    var type: String = ""
    
    var headerHeights: [Int : CGFloat] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.closeBarButton.image = self.closeBarButton.image?.withRenderingMode(.alwaysOriginal)
        
        self.titleLabel.text = self.productName
        self.subTitleLabel.text = self.price > 0.0 ? String(format: "£ %.2f", self.price) : ""
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(cellType: ProductModifierCell.self)
        self.tableView.register(headerFooterViewType: ProductModifierHeader.self)
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self] (sender: UIButton) in
            self.getModifiers()
        }
        
        self.statefulView.autoPinEdgesToSuperviewEdges()
        
        self.getModifiers()
        self.calculateTotal()
        
        self.stepperView.minValue = 1
        self.stepperView.maxValue = 20
        self.stepperView.value = 1
        self.stepperView.delegate = self
        
    }
    
    //MARK: My Methods
    @discardableResult func calculateTotal() -> Double {
        let total = self.groups.reduce(0.0) { (total, group) -> Double in
            return total + group.modifiers.reduce(0.0) { (groupTotal, modifier) -> Double in
                return groupTotal + (modifier.isSelected ? modifier.price * Double(modifier.quantity) : 0.0)
            }
        }
        
        self.addToCartButton.setTitle(String(format: "Add To Cart - £ %.2f", (self.price * Double(self.stepperView.value)) + (total * Double(self.stepperView.value))), for: .normal)
        
        return total
    }
    
    func isDataValid() -> (isValid: Bool, section: Int?) {
        var isValid = true
        var section: Int? = nil
        
        for (groupIndex, group) in self.groups.enumerated() {
            if group.isRequired && group.selectedModifiersCount < group.min {
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
        cell.setupCell(modifier: item, group: group)
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
            
            if group.selectedModifiersQuantity < group.max {
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
        
        let params: [String : Any] = ["type" : self.type,
                                      "establishment_id" : self.establishmentId,
                                      "product_id" : self.productId]
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
        
//        var selectedModifiersDict: [String : Any] = [:]
//        for (index, item) in selectedModifier.enumerated() {
//            selectedModifiersDict["\(index)"] = item
//        }
        
        debugPrint("selected modifiers: \(selectedModifier)")
        
        let params: [String : Any] = ["id" : self.productId,
                                      "quantity" : self.stepperView.value,
                                      "establishment_id" : self.establishmentId,
                                      "modifier_details" : selectedModifier]
        
        self.addToCartButton.showLoader()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathCart, method: .post, encoding: JSONEncoding.default) { (response, serverError, error) in
            
            self.addToCartButton.hideLoader()
            
//            defer {
//                let foodCartInfo: FoodCartUpdatedObject = (food: food, previousQuantity: previousQuantity, barId: self.bar.id.value)
//                NotificationCenter.default.post(name: notificationNameFoodCartUpdated, object: foodCartInfo)
//            }
            
            guard error == nil else {
                KVNProgress.showError(withStatus: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                KVNProgress.showError(withStatus: serverError!.detail)
                return
            }
            
//            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
//                let editedFood = transaction.edit(food)
//                editedFood?.quantity.value = shouldAdd ? food.quantity.value + 1 : 0
//            })
        }
    }
}

//MARK: StepperViewDelegate
extension ProductModfiersViewController: StepperViewDelegate {
    func stepperView(stepperView: StepperView, valueChanged value: Int) {
        self.calculateTotal()
    }
}
