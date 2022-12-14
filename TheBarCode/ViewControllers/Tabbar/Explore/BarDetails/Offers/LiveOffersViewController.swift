//
//  ExploreLiveOffersViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import SJSegmentedScrollView
import CoreStore
import ObjectMapper
import Alamofire
import PureLayout
import FirebaseAnalytics

protocol LiveOffersViewControllerDelegate: class {
    func barLiveOffersController(controller: LiveOffersViewController, didSelectRowAt offer: LiveOffer)
}

class LiveOffersViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    var offers: [LiveOffer] = []
    var bar: Bar!

    weak var delegate: LiveOffersViewControllerDelegate!

    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    var loadingShareController: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUpStatefulTableView()
        self.reset()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.statefulTableView.innerTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My Methods
    
    func reset() {
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
        self.statefulTableView.innerTable.estimatedRowHeight = 250.0
        self.statefulTableView.innerTable.tableFooterView = UIView()
        self.statefulTableView.innerTable.separatorStyle = .none
        
        self.statefulTableView.innerTable.register(cellType: LiveOfferTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
        
        for aView in self.statefulTableView.innerTable.subviews {
            if aView.isMember(of: UIRefreshControl.self) {
                aView.removeFromSuperview()
                break
            }
        }
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension LiveOffersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: LiveOfferTableViewCell.self)
        cell.setUpDetailCell(offer: self.offers[indexPath.row], topPadding: indexPath.row != 0)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let offerCell = cell as! LiveOfferTableViewCell
        offerCell.startTimer(deal: self.offers[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let offerCell = cell as! LiveOfferTableViewCell
        offerCell.stopTimer()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Analytics.logEvent(barClickFromExplore, parameters: nil)

        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        self.delegate.barLiveOffersController(controller: self, didSelectRowAt: self.offers[indexPath.row])
    }
}

//MARK: LiveOfferTableViewCellDelegate
extension LiveOffersViewController: LiveOfferTableViewCellDelegate {
    
    func liveOfferCell(cell: LiveOfferTableViewCell, bookmarButtonTapped sender: UIButton) {
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("IndexPath not found")
            return
        }
        
        let offer = self.offers[indexPath.row]
        self.updateBookmarkStatus(offer: offer, isBookmarked: !offer.isBookmarked.value)
    }
    
    func liveOfferCell(cell: LiveOfferTableViewCell, distanceButtonTapped sender: UIButton) {
        
    }
    
    func liveOfferCell(cell: LiveOfferTableViewCell, shareButtonTapped sender: UIButton) {
        
        guard !self.loadingShareController else {
            debugPrint("Loading sharing controller is already in progress")
            return
        }
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        self.loadingShareController = true
        
        let offer = self.offers[indexPath.row]
        offer.showSharingLoader = true
        self.statefulTableView.innerTable.reloadData()
        
        Utility.shared.generateAndShareDynamicLink(deal: offer, controller: self, presentationCompletion: {
            offer.showSharingLoader = false
            self.statefulTableView.innerTable.reloadData()
            self.loadingShareController = false
        }) {
            
        }
    }
}

//MARK: Webservices Methods
extension LiveOffersViewController {
   
    func getOffers(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.loadMore = Pagination()
        }

        let params:[String : Any] = ["establishment_id": self.bar.id.value,
                                      "type" : "live",
                                      "pagination" : true,
                                      "page": self.loadMore.next]
        
        self.loadMore.isLoading = true
        self.dataRequest  = APIHelper.shared.hitApi(params: params, apiPath: apioffer, method: .get) { (response, serverError, error) in
            
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
                
                var importedObjects: [LiveOffer] = []
                try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                    let objects = try! transaction.importUniqueObjects(Into<LiveOffer>(), sourceArray: responseArray)
                    importedObjects.append(contentsOf: objects)
                })
                
                for object in importedObjects {
                    let fetchedObject = Utility.barCodeDataStack.fetchExisting(object)
                    self.offers.append(fetchedObject!)
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
    
    func updateBookmarkStatus(offer: LiveOffer, isBookmarked: Bool) {
        
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
            
            self.statefulTableView.innerTable.reloadData()
            
            if isBookmarked {
                NotificationCenter.default.post(name: notificationNameBookmarkAdded, object: offer)
            } else {
                NotificationCenter.default.post(name: notificationNameBookmarkRemoved, object: offer)
            }
        }
        
    }
}

//MARK: StatefulTableDelegate
extension LiveOffersViewController: StatefulTableDelegate {
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
        
        initialErrorView.clearConstraints()
        
        initialErrorView.activityIndicator.autoPinEdge(ALEdge.top, to: ALEdge.top, of: initialErrorView, withOffset: 26.0)
        initialErrorView.activityIndicator.autoAlignAxis(ALAxis.vertical, toSameAxisOf: initialErrorView)
        
        return initialErrorView
    }
    
    func statefulTableViewInitialErrorView(tvc: StatefulTableView, forInitialLoadError: NSError?) -> UIView? {
        if forInitialLoadError == nil {
            let title = "No Live Offers Available"
            let subTitle = "Tap to refresh"
            
            let emptyDataView = EmptyDataView.loadFromNib()
            emptyDataView.setTitle(title: title, desc: subTitle, iconImageName: "icon_loading", buttonTitle: "")
           
            emptyDataView.clearConstraints()
            
            emptyDataView.titleLabel.autoPinEdge(ALEdge.top, to: ALEdge.top, of: emptyDataView, withOffset: 26.0)
            emptyDataView.titleLabel.autoPinEdge(ALEdge.leading, to: ALEdge.leading, of: emptyDataView, withOffset: 16.0)
            emptyDataView.titleLabel.autoPinEdge(ALEdge.trailing, to: ALEdge.trailing, of: emptyDataView, withOffset: -16.0)
            
            emptyDataView.descriptionLabel.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: emptyDataView.titleLabel, withOffset: 16.0)
            emptyDataView.descriptionLabel.autoPinEdge(ALEdge.leading, to: ALEdge.leading, of: emptyDataView, withOffset: 16.0)
            emptyDataView.descriptionLabel.autoPinEdge(ALEdge.trailing, to: ALEdge.trailing, of: emptyDataView, withOffset: -16.0)
            
            emptyDataView.actionButton.autoPinEdge(ALEdge.top, to: ALEdge.top, of: emptyDataView.titleLabel, withOffset: 0.0)
            emptyDataView.actionButton.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: emptyDataView.descriptionLabel, withOffset: 0.0)
            emptyDataView.actionButton.autoPinEdge(ALEdge.leading, to: ALEdge.leading, of: emptyDataView, withOffset: 0.0)
            emptyDataView.actionButton.autoPinEdge(ALEdge.trailing, to: ALEdge.trailing, of: emptyDataView, withOffset: 0.0)

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
