//
//  DrinkSearchViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 19/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import Reusable
import CoreStore
import ObjectMapper
import GoogleMaps
import Alamofire
import KVNProgress

class DrinkSearchViewController: BaseSearchScopeViewController {

    var searchResults: [ScopeSearchResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(drinkCartUpdatedNotification(notification:)), name: notificationNameDrinkCartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myCartUpdatedNotification(notification:)), name: notificationNameMyCartUpdated, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameDrinkCartUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameMyCartUpdated, object: nil)
    }
    
    //MARK: My Methods
    override func setUpStatefulTableView() {
        super.setUpStatefulTableView()
        
        self.statefulTableView.innerTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.statefulTableView.frame.size.width, height: 16.0))
        self.statefulTableView.innerTable.register(headerFooterViewType: ScopeSearchResultHeaderView.self)
        self.statefulTableView.innerTable.register(headerFooterViewType: FoodSearchFooterView.self)
        self.statefulTableView.innerTable.register(cellType: FoodMenuCell.self)
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
        
        self.searchResults.removeAll()
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
extension DrinkSearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
        self.scrollDidScroll(scrollView: scrollView)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let result = self.searchResults[section]
        if result.drinks.count > 3 {
            if result.isExpanded {
                return self.searchResults[section].drinks.count
            } else {
                return 3
            }
        } else {
            return self.searchResults[section].drinks.count
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? ScopeSearchResultHeaderView {
            let bar = self.searchResults[section].bar
            
            headerView.scrollToCurrentImage()
            
            let imageCount = bar.images.value.count
            
            headerView.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let headerView = view as? ScopeSearchResultHeaderView {
            headerView.pagerView.automaticSlidingInterval = 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.statefulTableView.innerTable.dequeueReusableHeaderFooterView(ScopeSearchResultHeaderView.self)
        headerView?.setUpCell(explore: self.searchResults[section].bar)
        headerView?.delegate = self
        headerView?.section = section
        
        let previousSection = section - 1
        if previousSection > 0 {
            let result = self.searchResults[previousSection]
            headerView?.pagerViewTop.constant = result.drinks.count > 3 ? 0.0 : 16.0
        } else {
            headerView?.pagerViewTop.constant = 16.0
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: FoodMenuCell.self)
        
        let drink = self.searchResults[indexPath.section].drinks[indexPath.row]
        cell.setupCellForDrink(drink: drink, isInAppPaymentOn: self.searchResults[indexPath.section].bar.isInAppPaymentOn.value)
        cell.separatorView.isHidden = false
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let result = self.searchResults[section]
        if result.drinks.count > 3 {
            let footerView = self.statefulTableView.innerTable.dequeueReusableHeaderFooterView(FoodSearchFooterView.self)
            footerView?.section = section
            footerView?.delegate = self
            footerView?.setupFooterView(searchResult: result)
            return footerView
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let results = self.searchResults[section]
        if results.drinks.count > 3 {
            return 62.0
        } else {
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let bar = self.searchResults[indexPath.section].bar
        self.moveToBarDetails(barId: bar.id.value, scopeType: .drink)
    }
}

//MARK: FoodMenuCellDelegate
extension DrinkSearchViewController: FoodMenuCellDelegate {
    func foodMenuCell(cell: FoodMenuCell, removeFromCartButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let bar = self.searchResults[indexPath.section].bar
        let model = self.searchResults[indexPath.section].drinks[indexPath.row]
        self.updateCart(drink: model, barId: bar.id.value, shouldAdd: false)
    }
    
    func foodMenuCell(cell: FoodMenuCell, addToCartButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let bar = self.searchResults[indexPath.section].bar
        let model = self.searchResults[indexPath.section].drinks[indexPath.row]
        self.updateCart(drink: model, barId: bar.id.value, shouldAdd: true)
    }
}

//MARK: FoodSearchFooterViewDelegate
extension DrinkSearchViewController: FoodSearchFooterViewDelegate {
    func foodSearchFooterView(footerView: FoodSearchFooterView, showResultsButtonTapped sender: UIButton) {
        let result = self.searchResults[footerView.section]
        result.isExpanded = !result.isExpanded
        self.statefulTableView.innerTable.reloadData()
    }
}

//MARK: ScopeSearchResultHeaderViewDelegate
extension DrinkSearchViewController: ScopeSearchResultHeaderViewDelegate {
    func scopeSearchResultHeaderView(headerView: ScopeSearchResultHeaderView, detailsButtonTapped sender: UIButton) {
        let bar = self.searchResults[headerView.section].bar
        self.moveToBarDetails(barId: bar.id.value, scopeType: .drink)
    }
}

//MARK: Webservices Methods
extension DrinkSearchViewController {
    
    func getBars(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        self.dataRequest?.cancel()
        
        if isRefreshing {
            self.loadMore.next = 1
        }
        
        var params:[String : Any] =  ["type": SearchScope.drink.rawValue,
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
        
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathMenu, method: .get) { (response, serverError, error) in
            
            defer {
                self.statefulTableView.innerTable.reloadData()
            }
            
            if isRefreshing {
                self.searchResults.removeAll()
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
                
                for responseObject in responseArray {
                    
                    var bar: Bar!
                    var drinks: [Drink] = []
                    try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                        
                        var mutableBarDict = responseObject
                        mutableBarDict["mapping_type"] = ExploreMappingType.bars.rawValue
                        bar = try! transaction.importUniqueObject(Into<Bar>(), source: mutableBarDict)
                        
                        let drinksArray = responseObject["menus"] as? [[String : Any]] ?? []
                        drinks = try! transaction.importUniqueObjects(Into<Drink>(), sourceArray: drinksArray)
                    })
                    
                    let fetchedBar = Utility.barCodeDataStack.fetchExisting(bar)
                    var fetchedDrinks: [Drink] = []
                    for drinks in drinks {
                        let fetchedDrink  = Utility.barCodeDataStack.fetchExisting(drinks)
                        fetchedDrinks.append(fetchedDrink!)
                    }
                    
                    let resultItem = ScopeSearchResult(bar: fetchedBar!, drinks: fetchedDrinks)
                    self.searchResults.append(resultItem)
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
        
        var params:[String : Any] =  ["type": SearchScope.drink.rawValue,
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
        self.mapDataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathMenu, method: .get) { (response, serverError, error) in
            
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
    
    func updateCart(drink: Drink, barId: String, shouldAdd: Bool) {
        
        var params: [String : Any] = ["id" : drink.id.value,
                                      "establishment_id" : barId]
        if shouldAdd {
            drink.isAddingToCart = true
            params["quantity"] = drink.quantity.value + 1
        } else {
            drink.isRemovingFromCart = true
            params["quantity"] = 0
        }
        
        self.statefulTableView.innerTable.reloadData()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathCart, method: .post) { (response, serverError, error) in
            
            let previousQuantity = drink.quantity.value
            
            defer {
                drink.isAddingToCart = false
                drink.isRemovingFromCart = false

                let drinkCartInfo: DrinkCartUpdatedObject = (drink: drink, previousQuantity: previousQuantity, barId: barId)
                NotificationCenter.default.post(name: notificationNameDrinkCartUpdated, object: drinkCartInfo)
            }
            
            guard error == nil else {
                KVNProgress.showError(withStatus: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                KVNProgress.showError(withStatus: serverError!.detail)
                return
            }
            
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let editedDrink = transaction.edit(drink)
                editedDrink?.quantity.value = shouldAdd ? drink.quantity.value + 1 : 0
            })
        }
    }
}

//MARK: StatefulTableDelegate
extension DrinkSearchViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        
        self.resetCurrentData()
        self.getBars(isRefreshing: false) {  [unowned self] (error) in
            handler(self.searchResults.count == 0, error)
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
            handler(self.searchResults.count == 0, error)
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

//MARK: Notification Methods
extension DrinkSearchViewController {
    @objc func drinkCartUpdatedNotification(notification: Notification) {
        self.statefulTableView.innerTable.reloadData()
    }
    
    @objc func myCartUpdatedNotification(notification: Notification) {
        self.statefulTableView.innerTable.reloadData()
    }
}
