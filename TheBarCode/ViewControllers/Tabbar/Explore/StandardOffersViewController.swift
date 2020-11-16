//
//  StandardOffersViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 18/02/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore

protocol StandardOffersViewControllerDelegate: class {
    func standardOffersViewController(controller: StandardOffersViewController, didSelectStandardOffers selectedOffers: [StandardOffer], redeemingType: RedeemingTypeModel?)

}

class StandardOffersViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var continueButton: UIButton!
    
    var offers: [StandardOffer] = []
    var redeemingTypes: [RedeemingTypeModel] = []
    
    var statefulView: LoadingAndErrorView!
    
    let transaction = Utility.barCodeDataStack.beginUnsafe()
    
    weak var delegate: StandardOffersViewControllerDelegate?
    
    var preSelectedTiers: [StandardOffer] = []
    
    var shouldDismiss: Bool = false
    
    var dataFetched: Bool = false
    
    var preSelectedRedeemingType: RedeemingTypeModel? = nil
    
    var hasChanges: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Filters"
        
        let backImage = UIImage(named: "icon_back")?.withRenderingMode(.alwaysOriginal)
        let cancelBarButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(cancelBarButtonTapped(sender:)))
        self.navigationItem.leftBarButtonItem = cancelBarButton
        
        self.continueButton.setTitle("Update", for: .normal)
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self] (sender: UIButton) in
            self.getOffers()
        }
        
        self.statefulView.autoPinEdgesToSuperviewEdges()
        
        self.tableView.estimatedRowHeight = 61.0
        self.tableView.rowHeight = 61.0
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundView = nil
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.register(cellType: FilterCell.self)
        self.tableView.register(cellType: RedeemingTypeCell.self)
        self.tableView.register(cellType: DeliveryFilterCell.self)
        self.tableView.register(headerFooterViewType: FiltersHeaderView.self)
        
        self.getCachedOffers()
        self.setUpPreselectedOffers()
        
        if self.offers.count == 0 {
            self.getOffers()
        } else {
            self.dataFetched = true
            self.statefulView.isHidden = true
        }
        
        self.redeemingTypes = RedeemingType.allTypes()
        if let preSelectedRedeemingType = preSelectedRedeemingType,
            let selectedType = self.redeemingTypes.first(where: {$0.type.rawValue == preSelectedRedeemingType.type.rawValue}) {
            selectedType.selected = true
        } else {
            let redeemingTypeAll = self.redeemingTypes.first!
            redeemingTypeAll.selected = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    //MARK: My Methods
    @objc func cancelBarButtonTapped(sender: UIBarButtonItem) {
        if shouldDismiss {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getCachedOffers() {
        self.offers = try! self.transaction.fetchAll(From<StandardOffer>().orderBy(OrderBy.SortKey.ascending(String(keyPath: \StandardOffer.discountValue))))
    }
    
    func setUpPreselectedOffers() {
        for offer in self.offers {
            if let _ = self.preSelectedTiers.first(where: {$0.id.value == offer.id.value}) {
                offer.isSelected.value = true
            } else {
                offer.isSelected.value = false
            }
        }
    }
    
    //MARK: My IBActions
    
    @IBAction func continueButtonTapped(sender: UIButton) {
        
        let selectedStandardOffers = self.offers.compactMap { (offer) -> StandardOffer? in
            if offer.isSelected.value {
                return offer
            } else {
                return nil
            }
        }

        var fetchedOffers: [StandardOffer] = []
        for object in selectedStandardOffers {
            let fetchedObject = Utility.barCodeDataStack.fetchExisting(object)
            fetchedOffers.append(fetchedObject!)
        }
        
        let selectedRedeemingType = self.redeemingTypes.first(where: {$0.selected})!

        if self.shouldDismiss && !self.hasChanges {
            self.dismiss(animated: true, completion: nil)
        } else {
            let redeemType = selectedRedeemingType.type == .all ? nil : selectedRedeemingType
            self.delegate?.standardOffersViewController(controller: self, didSelectStandardOffers: fetchedOffers, redeemingType: redeemType)
            
            self.navigationController?.popViewController(animated: true)
        }
        
        self.transaction.flush()
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension StandardOffersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.dataFetched else {
            return 0
        }
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 61.0
        } else {
            return 47.0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.offers.count
        } else {
            return self.redeemingTypes.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.tableView.dequeueReusableHeaderFooterView(FiltersHeaderView.self)
        if section == 0 {
            headerView?.setupHeader(title: "STANDARD OFFERS")
        } else if section == 1 {
            headerView?.setupHeader(title: "REDEEMING TYPES")
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: FilterCell.self)
            cell.setUpCell(offer: self.offers[indexPath.row])
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 68.0, bottom: 0.0, right: 0.0)
            return cell
            
        } else if indexPath.section == 1 {
            let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: RedeemingTypeCell.self)
            cell.setupCell(redeemingType: self.redeemingTypes[indexPath.row])
            cell.separatorInset = UIEdgeInsets(top: 0.0, left: 10000.0, bottom: 0.0, right: 0.0)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        self.hasChanges = true
        
        if indexPath.section == 0 {
            let offer = self.offers[indexPath.item]
            offer.isSelected.value = !offer.isSelected.value
            self.tableView.reloadRows(at: [indexPath], with: .none)
            
        } else if indexPath.section == 1 {
            for type in self.redeemingTypes {
                type.selected = false
            }
            
            let type = self.redeemingTypes[indexPath.row]
            type.selected = true
            self.tableView.reloadData()
        }
        
    }
}

//MARK: Webservices Methods
extension StandardOffersViewController {
    func getOffers() {
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathStandardOffers, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap To refresh")
                return
            }
            
            guard serverError == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To refresh")
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseOffers = (responseDict?["data"] as? [[String : Any]]) {
                self.offers.removeAll()
                
                let dataStack = Utility.barCodeDataStack
                try! dataStack.perform(synchronous: { (transaction) -> Void in
                    let importedObjects = try! transaction.importUniqueObjects(Into<StandardOffer>(), sourceArray: responseOffers)
                    debugPrint("Imported Standard Offers count: \(importedObjects.count)")
                })
                
                self.getCachedOffers()
                self.setUpPreselectedOffers()
                
                self.dataFetched = true
                
                self.tableView.reloadData()
                
                self.statefulView.isHidden = true
                self.statefulView.showNothing()
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To refresh")
            }
        }
    }
}
