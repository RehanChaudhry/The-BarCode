//
//  BarSearchViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 19/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore
import ObjectMapper
import PureLayout
import Alamofire
import CoreLocation
import GoogleMaps
import StatefulTableView

class BarSearchViewController: BaseSearchScopeViewController {
    
    var bars: [Bar] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    

    //MARK: My Methods
    override func setUpStatefulTableView() {
        super.setUpStatefulTableView()
        
        self.statefulTableView.innerTable.register(cellType: BarTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self

    }
    
    override func prepareToReset() {
        super.prepareToReset()
        
        self.dataRequest?.cancel()
        self.resetCurrentData()
        self.statefulTableView.state = .idle
    }
    
    override func reset() {
        super.reset()

        self.prepareToReset()
        self.loadMore.next = 1
        self.statefulTableView.triggerInitialLoad()
    }
    
    override func resetCurrentData() {
        super.resetCurrentData()
        
        self.bars.removeAll()
        self.statefulTableView.innerTable.reloadData()
    }
    
    override func setUpMapViewForLocations() {
        
        super.setUpMapViewForLocations()
        
        self.mapErrorView.isHidden = true
        self.mapLoadingIndicator.startAnimating()
        self.mapReloadButton.isHidden = true
        
        self.getBarsForMap { (error) in
            
            self.mapLoadingIndicator.stopAnimating()
            self.mapReloadButton.isHidden = false
            
            guard error == nil else {
                debugPrint("Error while getting basic map bars: \(error!)")
                self.mapErrorView.isHidden = false
                return
            }
            
            self.mapErrorView.isHidden = true
            self.setUpMarkers()
        }
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension BarSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
        self.scrollDidScroll(scrollView: scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: BarTableViewCell.self)
        cell.setUpCell(bar: self.bars[indexPath.row])
        cell.delegate = self
        cell.exploreBaseDelegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let aCell = cell as? BarTableViewCell {
            aCell.scrollToCurrentImage()
            
            let bar = self.bars[indexPath.row]
            let imageCount = bar.images.value.count
            
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let aCell = cell as? BarTableViewCell {
            aCell.pagerView.automaticSlidingInterval = 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        let bar = self.bars[indexPath.row]
        self.moveToBarDetails(barId: bar.id.value, scopeType: .bar)
    }
}

//MARK: ExploreBaseTableViewCellDelegate
extension BarSearchViewController: ExploreBaseTableViewCellDelegate {
    func exploreBaseTableViewCell(cell: ExploreBaseTableViewCell, didSelectItem itemIndexPath: IndexPath) {
        guard let tableCellIndexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        self.moveToBarDetails(barId: self.bars[tableCellIndexPath.row].id.value, scopeType: .bar)
    }
}

//MARK: BarTableViewCellDelegare
extension BarSearchViewController: BarTableViewCellDelegare {
    func barTableViewCell(cell: BarTableViewCell, favouriteButton sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let bar = self.bars[indexPath.row]
        markFavourite(bar: bar, cell: cell)
    }
    
    func barTableViewCell(cell: BarTableViewCell, distanceButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let bar = self.bars[indexPath.row]
        self.showDirection(bar: bar)
    }
}

//MARK: Webservices Methods
extension BarSearchViewController {
    
    func getBars(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        self.dataRequest?.cancel()
        
        if isRefreshing {
            self.loadMore.next = 1
        }
        
        var params:[String : Any] =  ["type": SearchScope.bar.rawValue,
                                      "pagination" : true,
                                      "is_for_map" : false,
                                      "page" : self.loadMore.next,
                                      "keyword" : self.keyword]
        
        if self.selectedPreferences.count > 0 {
            let ids = self.selectedPreferences.map({$0.id.value})
            params["interest_ids"] = ids
        }
        
        if self.selectedStandardOffers.count > 0 {
            let ids = self.selectedStandardOffers.map({$0.id.value})
            params["tier_ids"] = ids
        }
        
        if let _ = self.selectedDeliveryFilter {
            params["is_delivering"] = true
        }
        
        if let selectedRedeemingType = self.selectedRedeemingType {
            if selectedRedeemingType.type == .unlimited {
                params["is_unlimited_redemption"] = true
            } else if selectedRedeemingType.type == .limited {
                params["is_unlimited_redemption"] = false
            }
        }
        
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiEstablishment, method: .get) { (response, serverError, error) in
            
            defer {
                self.statefulTableView.innerTable.reloadData()
            }
            
            if isRefreshing {
                self.bars.removeAll()
            }
            
            guard error == nil else {
                completion(error! as NSError)
                return
            }
            
            guard serverError == nil else {
                completion(serverError!.nsError())
                return
            }

            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                
                var importedObjects: [Bar] = []
                try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                    for responseDict in responseArray {
                        var object = responseDict
                        object["mapping_type"] = ExploreMappingType.bars.rawValue
                        let importedObject = try! transaction.importUniqueObject(Into<Bar>(), source: object)
                        importedObjects.append(importedObject!)
                    }
                })
                
                for object in importedObjects {
                    let fetchedObject = Utility.barCodeDataStack.fetchExisting(object)
                    self.bars.append(fetchedObject!)
                }

                self.loadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                self.statefulTableView.canLoadMore = self.loadMore.canLoadMore()
                self.statefulTableView.canPullToRefresh = true
                self.statefulTableView.innerTable.reloadData()
                self.setUpMarkers()
                
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
    
    func getBarsForMap(completion: @escaping (_ error: NSError?) -> Void) {
        
        var params:[String : Any] =  ["type": SearchScope.bar.rawValue,
                                      "pagination" : false,
                                      "is_for_map" : true,
                                      "keyword" : self.keyword]
        
        if self.selectedPreferences.count > 0 {
            let ids = self.selectedPreferences.map({$0.id.value})
            params["interest_ids"] = ids
        }
        
        if self.selectedStandardOffers.count > 0 {
            let ids = self.selectedStandardOffers.map({$0.id.value})
            params["tier_ids"] = ids
        }
        
        if let _ = self.selectedDeliveryFilter {
            params["is_delivering"] = true
        }
        
        if let selectedRedeemingType = self.selectedRedeemingType {
            if selectedRedeemingType.type == .unlimited {
                params["is_unlimited_redemption"] = true
            } else if selectedRedeemingType.type == .limited {
                params["is_unlimited_redemption"] = false
            }
        }
        
        self.mapApiState.isLoading = true
        
        self.mapDataRequest?.cancel()
        self.mapDataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiEstablishment, method: .get) { (response, serverError, error) in
            
            self.mapApiState.isLoading = false
            
            guard error == nil else {
                self.mapApiState.error = error! as NSError
                completion(error! as NSError)
                return
            }
            
            guard serverError == nil else {
                self.mapApiState.error = serverError!.nsError()
                completion(serverError!.nsError())
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                
                self.mapBars.removeAll()
                
                let mapBars = Mapper<MapBasicBar>().mapArray(JSONArray: responseArray)
                self.mapBars.append(contentsOf: mapBars)
                
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
    
    func markFavourite(bar: Bar, cell: BarTableViewCell) {
        
        debugPrint("isFav == \(bar.isUserFavourite.value)")
        
        let params:[String : Any] = ["establishment_id": bar.id.value,
                                     "is_favorite" : !(bar.isUserFavourite.value)]
        
        try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
            let bars = try! transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), bar.id.value))
            for bar in bars {
                bar.isUserFavourite.value = !bar.isUserFavourite.value
            }
        })
        
        cell.setUpCell(bar: bar)
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiUpdateFavorite, method: .put) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("error == \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard serverError == nil else {
                debugPrint("servererror == \(String(describing: serverError?.errorMessages()))")
                return
            }
            
            let response = response as! [String : Any]
            let responseDict = response["response"] as! [String : Any]
            
            if let responseID = (responseDict["data"] as? Int) {
                debugPrint("responseID == \(responseID)")
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("genericError == \(String(describing: genericError.localizedDescription))")
            }
            
            if bar.isUserFavourite.value {
                NotificationCenter.default.post(name: notificationNameBarFavouriteAdded, object: bar)
            } else {
                NotificationCenter.default.post(name: notificationNameBarFavouriteRemoved, object: bar)
            }
        }
    }
}

//MARK: StatefulTableDelegate
extension BarSearchViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        
        self.resetCurrentData()
        self.getBars(isRefreshing: false) {  [unowned self] (error) in
            handler(self.bars.count == 0, error)
        }
        
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.getBars(isRefreshing: false) { (error) in
            handler(false, error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.refreshSnackBar()
        self.setUpMapViewForLocations()
        self.getBars(isRefreshing: true) { [unowned self] (error) in
            handler(self.bars.count == 0, error)
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
            let title = "Searching for something specific, why not type what you’re looking for in the search bar?"
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
