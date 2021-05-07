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
import MGSwipeTableCell
import FirebaseAnalytics
import CoreLocation

class SharedOffersViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    var offers: [Any] = []
    
    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    var showHideEmptyDatasetForcefully: Bool = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        self.setUpStatefulTableView()
        self.resetOffers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetAllSharedOfferNotificationReceived(notif:)), name: notificationNameReloadAllSharedOffers, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sharedOfferRemovedNotification(notif:)), name: notificationNameSharedOfferRemoved, object: nil)
        
        Analytics.logEvent(viewSharedOfferScreen, parameters: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.statefulTableView.innerTable.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameReloadAllSharedOffers, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameSharedOfferRemoved, object: nil)
    }
    
    //MARK: My Methods
    
    func resetOffers() {
        self.dataRequest?.cancel()
        self.loadMore = Pagination()
        self.offers.removeAll()
        self.statefulTableView.innerTable.reloadData()
        self.statefulTableView.state = .idle
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
        self.statefulTableView.innerTable.estimatedRowHeight = 310.0
        self.statefulTableView.innerTable.tableFooterView = UIView()
        self.statefulTableView.innerTable.separatorStyle = .none
        
        self.statefulTableView.innerTable.register(cellType: ShareOfferCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
    }
    
    func showDirection(bar: Bar){
        let mapUrl = "https://www.google.com/maps/dir/?api=1&destination=\(bar.latitude.value)+\(bar.longitude.value)"
        UIApplication.shared.open(URL(string: mapUrl)!, options: [:]) { (success) in
            
        }
    }
    
    func showBarDetail(bar: Bar) {
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
        barDetailNav.modalPresentationStyle = .fullScreen
        
        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
        barDetailController.selectedBar = bar
        barDetailController.delegate = self
        self.present(barDetailNav, animated: true, completion: nil)
    }
    
    func setupForEmptyDataSetIfNeeded() {
        if !self.loadMore.isLoading {
            self.showHideEmptyDatasetForcefully = true
            self.statefulTableView.triggerInitialLoad()
        }
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
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: ShareOfferCell.self)
        cell.sharingDelegate = self
        
        if let liveOffer = self.offers[indexPath.row] as? LiveOffer {
            cell.setUpCell(offer: liveOffer)
        } else if let deal = self.offers[indexPath.row] as? Deal {
            cell.setUpCell(offer: deal)
        }
        return cell
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        let offerDetailNavigation = self.storyboard!.instantiateViewController(withIdentifier: "OfferDetailNavigation") as! UINavigationController
        offerDetailNavigation.modalPresentationStyle = .fullScreen
        
        let deal = (self.offers[indexPath.row] as! Deal)
        
        let offerDetailController = offerDetailNavigation.viewControllers.first! as! OfferDetailViewController
        offerDetailController.isSharedOffer = true
        offerDetailController.deal = deal
        offerDetailController.bar = deal.establishment.value!
        offerDetailController.isPresenting = true
        
        self.present(offerDetailNavigation, animated: true, completion: nil)
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
                self.statefulTableView.innerTable.reloadData()
                completion(error! as NSError)
                return
            }
            
            guard serverError == nil else {
                self.loadMore.error = serverError!.nsError()
                self.statefulTableView.innerTable.reloadData()
                completion(serverError!.nsError())
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                
                if isRefreshing {
                    self.offers.removeAll()
                }
                
                var importedObjects: [Any] = []
                try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                    
                    for responseObject in responseArray {
                        let offerType = Utility.shared.checkDealType(offerTypeID: "\(responseObject["offer_type_id"]!)")
                        if offerType == .live {
                            let object = try! transaction.importUniqueObject(Into<LiveOffer>(), source: responseObject)
                            importedObjects.append(object as Any)
                        } else {
                            let object = try! transaction.importUniqueObject(Into<Deal>(), source: responseObject)
                            importedObjects.append(object as Any)
                        }
                        
                    }
                })
                
                for object in importedObjects {
                    if let object = object as? LiveOffer {
                        let fetchedObject = Utility.barCodeDataStack.fetchExisting(object)
                        self.offers.append(fetchedObject!)
                    } else if let object = object as? Deal {
                        let fetchedObject = Utility.barCodeDataStack.fetchExisting(object)
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
    
    func deleteSharedOffer(offer: Any) {
        
        var sharedId: String = ""
        if let liveOffer = offer as? LiveOffer {
            sharedId = liveOffer.sharedId.value!
        } else if let deal = offer as? Deal {
            sharedId = deal.sharedId.value!
        }
        
        let deleteSharedOffer = apiPathSharedOffers + "/" + sharedId
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: deleteSharedOffer, method: .delete) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("Error while deleting shared offer: \(error!.localizedDescription)")
                return
            }
            
            guard serverError == nil else {
                debugPrint("Server error while deleting shared offer: \(serverError!.errorMessages())")
                return
            }
            
            debugPrint("shared offer has been deleted: \(sharedId)")
            
        }
    }
}


//MARK: StatefulTableDelegate
extension SharedOffersViewController: StatefulTableDelegate {
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        if self.showHideEmptyDatasetForcefully {
            self.showHideEmptyDatasetForcefully = false
            handler(self.offers.count == 0, nil)
        } else {
            self.getOffers(isRefreshing: false) {  [unowned self] (error) in
                debugPrint("deal== \(self.offers.count)")
                handler(self.offers.count == 0, error)
            }
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
            let title = "No Shared Offer Available"
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

extension SharedOffersViewController: ShareOfferCellDelegate {
    func shareOfferCell(cell: ShareOfferCell, viewBarDetailButtonTapped sender: UIButton) {
        
        if let indexPath =  self.statefulTableView.innerTable.indexPath(for: cell) {
            if let liveOffer = self.offers[indexPath.row] as? LiveOffer {
                self.showBarDetail(bar: liveOffer.establishment.value!)
            } else if let deal = self.offers[indexPath.row] as? Deal {
                self.showBarDetail(bar: deal.establishment.value!)
            }
        } else {
            debugPrint("indexpath for cell not found")
        }
        
    }
    
    func shareOfferCell(cell: ShareOfferCell, viewDirectionButtonTapped sender: UIButton) {
      
        if let indexPath =  self.statefulTableView.innerTable.indexPath(for: cell) {
            if let liveOffer = self.offers[indexPath.row] as? LiveOffer {
                self.showDirection(bar: liveOffer.establishment.value!)
            } else if let deal = self.offers[indexPath.row] as? Deal {
                self.showDirection(bar: deal.establishment.value!)
            }
            
        } else {
            debugPrint("indexpath for cell not found")
        }
    }
    
    func shareOfferCell(cell: ShareOfferCell, deleteButtonTapped sender: MGSwipeButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let reachabilityManager = NetworkReachabilityManager()
        guard reachabilityManager?.isReachable == true else {
            self.showAlertController(title: "", msg: "No or weak internet connection")
            return
        }
        
        let sharedOffer = self.offers[indexPath.row]
        
        self.offers.remove(at: indexPath.row)
        self.statefulTableView.innerTable.deleteRows(at: [indexPath], with: .top)
        
        self.setupForEmptyDataSetIfNeeded()
        
        NotificationCenter.default.post(name: notificationNameSharedOfferRemoved, object: sharedOffer)
        
        self.deleteSharedOffer(offer: sharedOffer)
    }
    
    func shareOfferCell(cell: ShareOfferCell, shareButtonTapped sender: UIButton) {
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        if let liveOffer = self.offers[indexPath.row] as? LiveOffer {
            
            liveOffer.showSharingLoader = true
            self.statefulTableView.innerTable.reloadData()
            
            Utility.shared.generateAndShareDynamicLink(deal: liveOffer, controller: self, presentationCompletion: {
                
                liveOffer.showSharingLoader = false
                self.statefulTableView.innerTable.reloadData()
            }) {
                
            }
            
        } else if let deal = self.offers[indexPath.row] as? Deal {
            
            deal.showSharingLoader = true
            self.statefulTableView.innerTable.reloadData()
            
            Utility.shared.generateAndShareDynamicLink(deal: deal, controller: self, presentationCompletion: {
                
                deal.showSharingLoader = false
                self.statefulTableView.innerTable.reloadData()
            }) {
                
            }
        }

    }
}

//MARK: BarDetailViewControllerDelegate
extension SharedOffersViewController: BarDetailViewControllerDelegate {
    func barDetailViewController(controller: BarDetailViewController, cancelButtonTapped sender: UIBarButtonItem) {
        
    }
}

//MARK: Notification Methods
extension SharedOffersViewController {
    @objc func resetAllSharedOfferNotificationReceived(notif: Notification) {
        self.resetOffers()
    }
    
    @objc func sharedOfferRemovedNotification(notif: Notification) {
        guard let offerId = (notif.object as? Deal)?.id.value else {
            debugPrint("Offer id not available")
            return
        }
        
        let offerIndex = self.offers.firstIndex { (offer) -> Bool in
            if let deal = offer as? Deal {
                return deal.id.value == offerId
            } else {
                return false
            }
        }
        
        guard let index = offerIndex else {
            debugPrint("Offer id does not exist to remove")
            return
        }
        
        self.offers.remove(at: index)
        self.statefulTableView.innerTable.reloadData()
        
        self.setupForEmptyDataSetIfNeeded()
    }
}
