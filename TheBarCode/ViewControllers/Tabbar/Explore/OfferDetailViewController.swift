//
//  OfferDetailViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable

class OfferDetailViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet weak var redeemButton: GradientButton!
    
    var images: [String] = []
    
    var deal: Deal!
    
    var offerType : OfferType = .unknown
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.collectionView.register(cellType: ExploreDetailHeaderCollectionViewCell.self)
        
        self.tableView.register(cellType: OfferDetailTableViewCell.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = UIColor.clear
        
        self.tableView.estimatedRowHeight = 250.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.images = [deal.image.value]
       
        self.offerType = checkDealType()
        if self.offerType == .bannerAds {
            self.redeemButton.isHidden = true
        } else {
            self.redeemButton.isHidden = false
        }
        
        //TODO
//        if let offer = self.deal.offer.value {
//            if offer.type == .bannerAds {
//                self.redeemButton.isHidden = true
//            }
//        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let collectionViewHeight = ((273.0 / 375.0) * self.view.frame.width)
        let headerViewHeight = collectionViewHeight + 83.0
        
        var headerFrame = self.headerView.frame
        headerFrame.size.width = self.view.frame.width
        headerFrame.size.height = headerViewHeight
        self.headerView.frame = headerFrame
    }
    
    func checkDealType() -> OfferType {
        switch deal.offerTypeId.value {
        case "1":
            return OfferType.live
        case "2":
            return OfferType.standard
        case "3":
            return OfferType.exclusive
        case "4":
            return OfferType.bannerAds
        case "5":
            return OfferType.fiveADay
        default:
            return OfferType.unknown

        }
    }
    
    
    //MARK: IBAction
    @IBAction func redeemDealButtonTapped(_ sender: Any) {
        
        let bar = self.deal.establishment.value!
        if bar.canRedeemOffer.value {
            if self.offerType == .exclusive {
                //for exclusive
                let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
                redeemStartViewController.deal = self.deal
                redeemStartViewController.modalPresentationStyle = .overCurrentContext
                redeemStartViewController.redeemWithCredit = false
                self.present(redeemStartViewController, animated: true, completion: nil)

            } else if self.offerType == .live {
                //for live offer deals
                redeemDeal(redeemWithCredit: false)
            }

        } else {
            if bar.credit.value > 0 {
                let creditConsumptionController = self.storyboard?.instantiateViewController(withIdentifier: "CreditCosumptionViewController") as! CreditCosumptionViewController
                creditConsumptionController.delegate = self
                creditConsumptionController.modalPresentationStyle = .overCurrentContext
                self.present(creditConsumptionController, animated: true, completion: nil)
                
                
            } else {
                let outOfCreditViewController = (self.storyboard?.instantiateViewController(withIdentifier: "OutOfCreditViewController") as! OutOfCreditViewController)
                outOfCreditViewController.delegate = self
                outOfCreditViewController.modalPresentationStyle = .overCurrentContext
                self.present(outOfCreditViewController, animated: true, completion: nil)
            }
        }
    
    }

}

//MARK: UITableViewDelegate, UITableViewDataSource
extension OfferDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: OfferDetailTableViewCell.self)
        cell.configCell(deal: self.deal)
        return cell
    }
}


//MARK: UICollectionViewDataSource, UICollectionViewDelegate
extension OfferDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.collectionView.dequeueReusableCell(for: indexPath, cellType: ExploreDetailHeaderCollectionViewCell.self)
        cell.setUpCell(imageName: self.images[indexPath.item])
        return cell
    }
    
}

//MARK: UICollectionViewDelegateFlowLayout
extension OfferDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionView.frame.size
    }
}


extension OfferDetailViewController: CreditCosumptionViewControllerDelegate {
    func creditConsumptionViewController(controller: CreditCosumptionViewController, yesButtonTapped sender: UIButton, selectedIndex: Int) {

        if self.offerType == .exclusive {
            //for exclusive
            let redeemStartViewController = (self.storyboard?.instantiateViewController(withIdentifier: "RedeemStartViewController") as! RedeemStartViewController)
            redeemStartViewController.deal = self.deal
            redeemStartViewController.redeemWithCredit = true
            redeemStartViewController.modalPresentationStyle = .overCurrentContext
            self.present(redeemStartViewController, animated: true, completion: nil)
        } else if self.offerType == .live {
            //for live
            redeemDeal(redeemWithCredit: true)
        }
    }
    
    func creditConsumptionViewController(controller: CreditCosumptionViewController, noButtonTapped sender: UIButton, selectedIndex: Int) {
    }
}


extension OfferDetailViewController: OutOfCreditViewControllerDelegate {
    func outOfCreditViewController(controller: OutOfCreditViewController, closeButtonTapped sender: UIButton, selectedIndex: Int) {
    }
    
    func outOfCreditViewController(controller: OutOfCreditViewController, reloadButtonTapped sender: UIButton, selectedIndex: Int) {
        
    }
    
    func outOfCreditViewController(controller: OutOfCreditViewController, inviteButtonTapped sender: UIButton, selectedIndex: Int) {
        
    }
}

//MARK: WebService Method
extension OfferDetailViewController {
    func redeemDeal(redeemWithCredit: Bool) {
        
        UIApplication.shared.beginIgnoringInteractionEvents()
        self.redeemButton.showLoader()
        
        let redeemType = redeemWithCredit ? RedeemType.credit : RedeemType.any
        
        let params: [String: Any] = ["establishment_id": deal.establishmentId.value,
                                     "type": redeemType.rawValue,
                                     "offer_id" : deal.id.value]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiOfferRedeem, method: .post) { (response, serverError, error) in
            
            self.redeemButton.hideLoader()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            guard error == nil else {
                self.showAlertController(title: "", msg: error?.localizedDescription ?? genericErrorMessage)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "", msg: serverError?.errorMessages() ?? genericErrorMessage)
                return
            }
            
            if let responseObj = response as? [String : Any] {
                if  let _ = responseObj["data"] as? [String : Any] {
                    
                    try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                        let editedObject = transaction.edit(self.deal)
                        editedObject!.establishment.value!.canRedeemOffer.value = false
                    })
                    
                    if redeemWithCredit {
                        Utility.shared.userCreditUpdate()
                    }
                    
                } else {
                    let genericError = APIHelper.shared.getGenericError()
                    self.showAlertController(title: "", msg: genericError.localizedDescription)
                }
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.showAlertController(title: "", msg: genericError.localizedDescription)
            }
        }
    }
}
