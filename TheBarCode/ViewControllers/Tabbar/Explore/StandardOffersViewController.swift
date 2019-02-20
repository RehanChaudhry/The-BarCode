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
    func standardOffersViewController(controller: StandardOffersViewController, didSelectStandardOffers selectedOffers: [StandardOffer])

}

class StandardOffersViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var continueButton: UIButton!
    
    var offers: [StandardOffer] = []
    
    var statefulView: LoadingAndErrorView!
    
    let transaction = Utility.inMemoryStack.beginUnsafe()
    
    weak var delegate: StandardOffersViewControllerDelegate?
    
    var preSelectedTiers: [StandardOffer] = []
    
    var shouldDismiss: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Standard Offers"
        let cancelBarButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(cancelBarButtonTapped(sender:)))
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
        self.tableView.register(cellType: StandardOfferTypeCell.self)
        
        self.getCachedOffers()
        self.setUpPreselectedOffers()
        
        if self.offers.count == 0 {
            self.getOffers()
        } else {
            self.statefulView.isHidden = true
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
        self.offers = self.transaction.fetchAll(From<StandardOffer>().orderBy(OrderBy.SortKey.ascending(String(keyPath: \StandardOffer.discountValue)))) ?? []
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
            let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
            fetchedOffers.append(fetchedObject!)
        }

        if self.shouldDismiss && selectedStandardOffers.count == 0 {
            self.dismiss(animated: true, completion: nil)
        } else {
            self.delegate?.standardOffersViewController(controller: self, didSelectStandardOffers: fetchedOffers)
            self.navigationController?.popViewController(animated: true)
        }
        
        self.transaction.flush()
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension StandardOffersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: StandardOfferTypeCell.self)
        cell.setUpCell(offer: self.offers[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let offer = self.offers[indexPath.item]
        offer.isSelected.value = !offer.isSelected.value
        self.tableView.reloadRows(at: [indexPath], with: .none)
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
                
                let dataStack = Utility.inMemoryStack
                try! dataStack.perform(synchronous: { (transaction) -> Void in
                    let importedObjects = try! transaction.importUniqueObjects(Into<StandardOffer>(), sourceArray: responseOffers)
                    debugPrint("Imported Standard Offers count: \(importedObjects.count)")
                })
                
                self.getCachedOffers()
                self.setUpPreselectedOffers()
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
