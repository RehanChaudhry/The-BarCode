//
//  BookmarkedOfferViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 02/08/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import PureLayout
import StatefulTableView
import CoreStore
import ObjectMapper
import Alamofire

class BookmarkedOfferViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
        
    var offers: [Any] = []
    
    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    var loadingShareController: Bool = false
    
    var showHideEmptyDatasetForcefully: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(offerBookmarkedNotification(notification:)), name: notificationNameBookmarkAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(offerBookmarkedRemovedNotification(notification:)), name: notificationNameBookmarkRemoved, object: nil)
        
        self.setUpStatefulTableView()
        self.statefulTableView.triggerInitialLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.statefulTableView.innerTable.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameBookmarkAdded, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameBookmarkRemoved, object: nil)
    }
    
    //MARK: My Methods
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
        
        self.statefulTableView.innerTable.register(cellType: DealTableViewCell.self)
        self.statefulTableView.innerTable.register(cellType: LiveOfferTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
    }

    func setupForEmptyDataSetIfNeeded() {
        if !self.loadMore.isLoading {
            self.showHideEmptyDatasetForcefully = true
            self.statefulTableView.triggerInitialLoad()
        }
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension BookmarkedOfferViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let object = self.offers[indexPath.row]
        if let liveOffer = object as? LiveOffer {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: LiveOfferTableViewCell.self)
            cell.setUpDetailCell(offer: liveOffer)
            cell.delegate = self
            return cell
        } else if let deal = object as? Deal {
            let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: DealTableViewCell.self)
            cell.setUpDealCell(deal: deal)
            cell.delegate = self
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let offerCell = cell as? LiveOfferTableViewCell, let liveOffer = self.offers[indexPath.row] as? LiveOffer {
            offerCell.startTimer(deal: liveOffer)
        } else if let dealCell = cell as? DealTableViewCell, let deal = self.offers[indexPath.row] as? Deal {
            dealCell.startTimer(deal: deal)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let offerCell = cell as? LiveOfferTableViewCell {
            offerCell.stopTimer()
        } else if let dealCell = cell as? DealTableViewCell {
            dealCell.stopTimer()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)

        guard let offer = self.offers[indexPath.row] as? Deal else {
            debugPrint("Deal not found")
            return
        }
        
        let offerDetailNavigation = self.storyboard!.instantiateViewController(withIdentifier: "OfferDetailNavigation") as! UINavigationController
        
        let offerDetailController = offerDetailNavigation.viewControllers.first! as! OfferDetailViewController
        offerDetailController.deal = offer
        offerDetailController.isPresenting = true
        
        self.present(offerDetailNavigation, animated: true, completion: nil)
    }
}

//MARK: DealTableViewCellDelegate
extension BookmarkedOfferViewController: DealTableViewCellDelegate {
    func dealTableViewCell(cell: DealTableViewCell, distanceButtonTapped sender: UIButton) {
        
    }
    
    func dealTableViewCell(cell: DealTableViewCell, shareButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        guard !self.loadingShareController else {
            debugPrint("Loading sharing controller is already in progress")
            return
        }
        
        guard let offer = self.offers[indexPath.row] as? Deal else {
            debugPrint("Not a deal")
            return
        }
        
        self.loadingShareController = true

        offer.showSharingLoader = true
        self.statefulTableView.innerTable.reloadData()
        
        Utility.shared.generateAndShareDynamicLink(deal: offer, controller: self, presentationCompletion: {
            offer.showSharingLoader = false
            self.statefulTableView.innerTable.reloadData()
            self.loadingShareController = false
        }) {
            
        }
    }
    
    func dealTableViewCell(cell: DealTableViewCell, bookmarkButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let offer = self.offers[indexPath.row]
        self.updateBookmarkStatus(offer: offer, isBookmarked: false)
    }
}

//MARK: LiveOfferTableViewCellDelegate
extension BookmarkedOfferViewController: LiveOfferTableViewCellDelegate {
    
    func liveOfferCell(cell: LiveOfferTableViewCell, distanceButtonTapped sender: UIButton) {
        
    }
    
    func liveOfferCell(cell: LiveOfferTableViewCell, shareButtonTapped sender: UIButton) {
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        guard let offer = self.offers[indexPath.row] as? LiveOffer else {
            debugPrint("Not a live offer")
            return
        }
        
        guard !self.loadingShareController else {
            debugPrint("Loading sharing controller is already in progress")
            return
        }
        
        self.loadingShareController = true
        
        offer.showSharingLoader = true
        self.statefulTableView.innerTable.reloadData()
        
        Utility.shared.generateAndShareDynamicLink(deal: offer, controller: self, presentationCompletion: {
            offer.showSharingLoader = false
            self.statefulTableView.innerTable.reloadData()
            self.loadingShareController = false
        }) {
            
        }
    }
    
    func liveOfferCell(cell: LiveOfferTableViewCell, bookmarButtonTapped sender: UIButton) {
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let offer = self.offers[indexPath.row]
        self.updateBookmarkStatus(offer: offer, isBookmarked: false)
    }
}

//MARK: Webservices Methods
extension BookmarkedOfferViewController {
    
    func getOffers(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.loadMore = Pagination()
        }
        
        let params: [String : Any] = ["pagination" : true,
                                      "page": self.loadMore.next]
        
        self.loadMore.isLoading = true
        self.dataRequest  = APIHelper.shared.hitApi(params: params, apiPath: apiPathBookmarkedOffers, method: .get) { (response, serverError, error) in
            
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
                    let corestoreObject = object as! CoreStoreObject
                    let fetchedObject = Utility.barCodeDataStack.fetchExisting(corestoreObject)
                    
                    self.offers.append(fetchedObject as Any)
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
    
    func updateBookmarkStatus(offer: Any, isBookmarked: Bool) {
        
        guard let offer = offer as? Deal else {
            debugPrint("Offer id not found")
            return
        }
        
        guard !offer.savingBookmarkStatus else {
            debugPrint("Already saving bookmark status")
            return
        }
        
        offer.savingBookmarkStatus = true
        self.statefulTableView.innerTable.reloadData()
        
        let offerId: String = offer.id.value
    
        let params: [String : Any] = ["offer_id" : offerId,
                                      "is_favorite" : isBookmarked]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathAddRemoveBookmarkedOffer, method: .put) { (response, serverError, error) in
            
            offer.savingBookmarkStatus = false
            
            let index = self.offers.firstIndex(where: { (obj) -> Bool in
                if let liveOffer = obj as? LiveOffer {
                    return liveOffer.id.value == offer.id.value
                } else if let deal = obj as? Deal {
                    return deal.id.value == offer.id.value
                } else {
                    return false
                }
            })
            
            guard error == nil else {
                self.statefulTableView.innerTable.reloadData()
                self.showAlertController(title: "", msg: error!.localizedDescription)
                debugPrint("Error while saving bookmark offer status: \(error!.localizedDescription)")
                return
            }
            
            guard serverError == nil else {
                self.statefulTableView.innerTable.reloadData()
                debugPrint("Server error while saving bookmark offer status: \(serverError!.errorMessages())")
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let edittedOffer = transaction.edit(offer)
                edittedOffer?.isBookmarked.value = isBookmarked
            })
            
            if let index = index {
                self.offers.remove(at: index)
                let indexPath = IndexPath(row: index, section: 0)
                self.statefulTableView.innerTable.deleteRows(at: [indexPath], with: .bottom)
            } else {
                self.statefulTableView.innerTable.reloadData()
            }
            
            self.setupForEmptyDataSetIfNeeded()
            
        }
        
    }
}


//MARK: StatefulTableDelegate
extension BookmarkedOfferViewController: StatefulTableDelegate {
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
            let title = "No Bookmarked Offer Available"
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

//MARK: Notification Methods
extension BookmarkedOfferViewController {
    
    @objc func offerBookmarkedNotification(notification: Notification) {
        let offer = notification.object!
        self.offers.insert(offer, at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        self.statefulTableView.innerTable.insertRows(at: [indexPath], with: .bottom)
        self.setupForEmptyDataSetIfNeeded()
    }
    
    @objc func offerBookmarkedRemovedNotification(notification: Notification) {

        guard let offer = notification.object as? Deal else {
            debugPrint("Offer id not found")
            return
        }
        
        let index = self.offers.firstIndex(where: { (obj) -> Bool in
            if let liveOffer = obj as? LiveOffer {
                return liveOffer.id.value == offer.id.value
            } else if let deal = obj as? Deal {
                return deal.id.value == offer.id.value
            } else {
                return false
            }
        })
        
        if let index = index {
            self.offers.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.statefulTableView.innerTable.deleteRows(at: [indexPath], with: .top)
        } else {
            self.statefulTableView.innerTable.reloadData()
        }
        
        self.setupForEmptyDataSetIfNeeded()
    }
}
