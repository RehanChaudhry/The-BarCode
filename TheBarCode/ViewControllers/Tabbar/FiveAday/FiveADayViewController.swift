//
//  FiveADayViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import FSPagerView
import ObjectMapper
import CoreStore

protocol FiveADayViewControllerDelegate {
    func showPopup(index: Int)
    func showDealDetail(index: Int)

}


class FiveADayViewController: UIViewController {

    @IBOutlet var pagerView: FSPagerView!
    
    @IBOutlet var pageControl: UIPageControl!
    
    var deals : [FiveADayDeal] = []
    
    var statefulView: LoadingAndErrorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //self.deals = FiveADayDeal.getDummyList()
        
        self.pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        self.pageControl.numberOfPages = deals.count
        self.pagerView.isInfinite = true
        self.pageControl.currentPage = 0
        self.pagerView.backgroundColor = .clear
        self.pagerView.automaticSlidingInterval = 4.0
        self.pagerView.register(FiveADayCollectionViewCell.nib, forCellWithReuseIdentifier: FiveADayCollectionViewCell.reuseIdentifier)
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {(sender: UIButton) in
            
        }
        
        self.statefulView.autoPinEdgesToSuperviewEdges()
        
        self.getFiveADayDeals()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.deals.removeAll()
        self.deals.append(contentsOf: Utility.inMemoryStack.fetchAll(From<FiveADayDeal>()) ?? [])
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let cellWidth = (self.view.frame.width / 100.0 * 85.0)
        let cellHeight = self.pagerView.frame.size.height
        
        self.pagerView.itemSize = CGSize(width: cellWidth, height: cellHeight)
    }
    
}

//MARK: FSPagerViewDataSource, FSPagerViewDelegate

extension FiveADayViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        self.pageControl.currentPage = pagerView.currentIndex
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        return false
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return deals.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let identifier = FiveADayCollectionViewCell.reuseIdentifier
        let cell = self.pagerView.dequeueReusableCell(withReuseIdentifier: identifier, at: index) as! FiveADayCollectionViewCell
        cell.delegate = self
        cell.setUpCell(deal: deals[index], index: index)
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
    }
}

//MARK: FiveADayViewControllerDelegate
extension FiveADayViewController: FiveADayViewControllerDelegate {
    
    func showPopup(index: Int) {
        let deal = self.deals[index]
        if let bar = deal.establishment.value {
            if bar.isOfferRedeemed.value {
                redeemFiveADayDeal(deal: deal)
            }
        }
    }
    
    func showDealDetail(index: Int){
        let fiveADayDetailViewController = (self.storyboard?.instantiateViewController(withIdentifier: "FiveADayDetailViewController") as! FiveADayDetailViewController)
        fiveADayDetailViewController.modalPresentationStyle = .overCurrentContext
        fiveADayDetailViewController.deal = deals[index]
        self.present(fiveADayDetailViewController, animated: true, completion: nil)
    }
}

//MARK: Webservices Methods
extension FiveADayViewController {
    func getFiveADayDeals() {
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathFiveADayDeals, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: error!.localizedDescription, reloadMessage: "Tap To Reload")
                return
            }
            
            guard serverError == nil else {
                self.statefulView.showErrorViewWithRetry(errorMessage: serverError!.errorMessages(), reloadMessage: "Tap To Reload")
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                
                
                var importedObjects: [FiveADayDeal] = []
                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                    let objects = try! transaction.importUniqueObjects(Into<FiveADayDeal>(), sourceArray: responseArray)
                    importedObjects.append(contentsOf: objects)
                })
                
                self.deals.removeAll()
                for object in importedObjects {
                    let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
                    self.deals.append(fetchedObject!)
                }
                
                if self.deals.isEmpty {
                    self.statefulView.showErrorViewWithRetry(errorMessage: "No Five A Day Deal Available", reloadMessage: "Tap To Refresh")
                } else {
                    self.statefulView.isHidden = true
                    self.statefulView.showNothing()
                }
                
                self.pagerView.reloadData()
                self.pageControl.numberOfPages = self.deals.count
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                self.statefulView.showErrorViewWithRetry(errorMessage: genericError.localizedDescription, reloadMessage: "Tap To Reload")
            }
        }
    }
}

//MARK: WebService Method
extension FiveADayViewController {
    func redeemFiveADayDeal(deal: FiveADayDeal) {
        
        let params: [String: Any] = ["establishment_id": deal.establishmentId.value,
                      "type": "reload",
                      "offer_id": deal.id.value ]
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiOfferRedeem, method: .post) { (response, serverError, error) in
            
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
                        let editedObject = transaction.edit(deal)
                        editedObject!.establishment.value!.isOfferRedeemed.value = false
                    })
                    
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
