//
//  SharedOffersViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 07/11/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Alamofire
import StatefulTableView
import ObjectMapper
import CoreStore

class SharedOffersViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    var offers: [Any] = []
    
    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        self.setUpStatefulTableView()
        self.resetOffers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My Methods
    
    func resetOffers() {
        self.dataRequest?.cancel()
        self.loadMore = Pagination()
        self.offers.removeAll()
        self.statefulTableView.reloadData()
        self.statefulTableView.triggerInitialLoad()
    }
    
    func setUpStatefulTableView() {
        
        self.statefulTableView.backgroundColor = .clear
        for aView in self.statefulTableView.subviews {
            aView.backgroundColor = .clear
        }
        
        self.statefulTableView.canLoadMore = false
        self.statefulTableView.canPullToRefresh = false
        self.statefulTableView.innerTable.rowHeight = UITableViewAutomaticDimension
        self.statefulTableView.innerTable.estimatedRowHeight = 250.0
        self.statefulTableView.innerTable.tableFooterView = UIView()
        self.statefulTableView.innerTable.separatorStyle = .none
        
        self.statefulTableView.innerTable.register(cellType: LiveOfferTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
    }
    
    //MARK: My IBActions
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

}

//MARK: UITableViewDataSource, UITableViewDelegate
extension SharedOffersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: LiveOfferTableViewCell.self)
        if let liveOffer = self.offers[indexPath.row] as? LiveOffer {
            cell.setUpDetailForSharedLiveOffer(offer: liveOffer)
        } else if let deal = self.offers[indexPath.row] as? Deal {
            cell.setUpDetailForSharedDeal(offer: deal)
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let offerCell = cell as! LiveOfferTableViewCell
        if let liveOffer = self.offers[indexPath.row] as? LiveOffer {
            offerCell.startTimer(deal: liveOffer)
        } else if let deal = self.offers[indexPath.row] as? Deal {
            offerCell.setUpDetailForSharedDeal(offer: deal)
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let offerCell = cell as! LiveOfferTableViewCell
        if let _ = self.offers[indexPath.row] as? LiveOffer {
            offerCell.stopTimer()
        } else if let deal = self.offers[indexPath.row] as? Deal {
            offerCell.setUpDetailForSharedDeal(offer: deal)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        let offerDetailController = self.storyboard?.instantiateViewController(withIdentifier: "OfferDetailViewController") as! OfferDetailViewController
        offerDetailController.isSharedOffer = true
        offerDetailController.deal = (self.offers[indexPath.row] as! Deal)
        self.navigationController?.pushViewController(offerDetailController, animated: true)
    }
}

//MARK: Webservices Methods
extension SharedOffersViewController {
    
    func getOffers(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.loadMore = Pagination()
        }
        
        let params:[String : Any] = ["pagination" : true,
                                     "page": self.loadMore.next]
        
        self.loadMore.isLoading = true
        self.dataRequest  = APIHelper.shared.hitApi(params: params, apiPath: apiPathSharedOffers, method: .get) { (response, serverError, error) in
            
            self.loadMore.isLoading = false
            
            guard error == nil else {
                self.loadMore.error = error! as NSError
                self.statefulTableView.reloadData()
                completion(error! as NSError)
                return
            }
            
            guard serverError == nil else {
                self.loadMore.error = serverError!.nsError()
                self.statefulTableView.reloadData()
                completion(serverError!.nsError())
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                
                if isRefreshing {
                    self.offers.removeAll()
                }
                
                var importedObjects: [Any] = []
                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                    
                    for responseObject in responseArray {
                        let offerType = Utility.shared.checkDealType(offerTypeID: "\(responseObject["offer_type_id"]!)")
                        if offerType == .live {
                            let object = try! transaction.importUniqueObject(Into<LiveOffer>(), source: responseObject)
                            importedObjects.append(object as Any)
                        } else if offerType == .fiveADay {
                            let object = try! transaction.importUniqueObject(Into<FiveADayDeal>(), source: responseObject)
                            importedObjects.append(object as Any)
                        }
                        
                    }
                })
                
                for object in importedObjects {
                    if let object = object as? LiveOffer {
                        let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
                        self.offers.append(fetchedObject!)
                    } else if let object = object as? FiveADayDeal {
                        let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
                        self.offers.append(fetchedObject!)
                    }
                }
                
                self.loadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                self.statefulTableView.canLoadMore = self.loadMore.canLoadMore()
                self.statefulTableView.canPullToRefresh = true
                self.statefulTableView.innerTable.reloadData()
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
}


//MARK: StatefulTableDelegate
extension SharedOffersViewController: StatefulTableDelegate {
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getOffers(isRefreshing: false) {  [unowned self] (error) in
            debugPrint("deal== \(self.offers.count)")
            handler(self.offers.count == 0, error)
        }
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.loadMore.error = nil
        tvc.innerTable.reloadData()
        
        self.getOffers(isRefreshing: false) { [unowned self] (error) in
            handler(self.loadMore.canLoadMore(), error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getOffers(isRefreshing: true) { [unowned self] (error) in
            handler(self.offers.count == 0, error)
        }
    }
    
    func statefulTableViewViewForInitialLoad(tvc: StatefulTableView) -> UIView? {
        let initialErrorView = LoadingAndErrorView.loadFromNib()
        initialErrorView.backgroundColor = .clear
        initialErrorView.showLoading()
        return initialErrorView
    }
    
    func statefulTableViewInitialErrorView(tvc: StatefulTableView, forInitialLoadError: NSError?) -> UIView? {
        if forInitialLoadError == nil {
            let title = "No Shared Offers Available"
            let subTitle = "Tap to refresh"
            
            let emptyDataView = EmptyDataView.loadFromNib()
            emptyDataView.setTitle(title: title, desc: subTitle, iconImageName: "icon_loading", buttonTitle: "")
            
            emptyDataView.actionHandler = { (sender: UIButton) in
                tvc.triggerInitialLoad()
            }
            
            return emptyDataView
            
        } else {
            let initialErrorView = LoadingAndErrorView.loadFromNib()
            initialErrorView.showErrorView(canRetry: true)
            initialErrorView.backgroundColor = .clear
            initialErrorView.showErrorViewWithRetry(errorMessage: forInitialLoadError!.localizedDescription, reloadMessage: "Tap to refresh")
            
            initialErrorView.retryHandler = {(sender: UIButton) in
                tvc.triggerInitialLoad()
            }
            
            return initialErrorView
        }
    }
    
    func statefulTableViewLoadMoreErrorView(tvc: StatefulTableView, forLoadMoreError: NSError?) -> UIView? {
        let loadingView = LoadingAndErrorView.loadFromNib()
        loadingView.showErrorView(canRetry: true)
        loadingView.backgroundColor = .clear
        
        if forLoadMoreError == nil {
            loadingView.showLoading()
        } else {
            loadingView.showErrorViewWithRetry(errorMessage: forLoadMoreError!.localizedDescription, reloadMessage: "Tap to refresh")
        }
        
        loadingView.retryHandler = {(sender: UIButton) in
            tvc.triggerLoadMore()
        }
        
        return loadingView
    }
}
