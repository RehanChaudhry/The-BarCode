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
        
        NotificationCenter.default.addObserver(self, selector: #selector(productCartUpdatedNotification(notification:)), name: notificationNameProductCartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myCartUpdatedNotification(notification:)), name: notificationNameMyCartUpdated, object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameProductCartUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameMyCartUpdated, object: nil)
    }
    
    //MARK: My Methods
    override func setUpStatefulTableView() {
        super.setUpStatefulTableView()
        
        self.statefulTableView.innerTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.statefulTableView.frame.size.width, height: 16.0))
        self.statefulTableView.innerTable.register(headerFooterViewType: ScopeSearchResultHeaderView.self)
        self.statefulTableView.innerTable.register(headerFooterViewType: FoodSearchFooterView.self)
        self.statefulTableView.innerTable.register(cellType: ProductMenuCell.self)
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
        if result.products.count > 3 {
            if result.isExpanded {
                return self.searchResults[section].products.count
            } else {
                return 3
            }
        } else {
            return self.searchResults[section].products.count
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
            headerView?.pagerViewTop.constant = result.products.count > 3 ? 0.0 : 16.0
        } else {
            headerView?.pagerViewTop.constant = 16.0
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: ProductMenuCell.self)
        
        let product = self.searchResults[indexPath.section].products[indexPath.row]
        cell.setupCell(product: product, bar: self.searchResults[indexPath.section].bar)
        cell.separatorView.isHidden = false
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let result = self.searchResults[section]
        if result.products.count > 3 {
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
        if results.products.count > 3 {
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

//MARK: ProductMenuCellDelegate
extension DrinkSearchViewController: ProductMenuCellDelegate {
    func productMenuCell(cell: ProductMenuCell, selectedIndexPath: IndexPath) {
        
    }
    
    func productMenuCell(cell: ProductMenuCell, removeFromCartButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let bar = self.searchResults[indexPath.section].bar
        let model = self.searchResults[indexPath.section].products[indexPath.row]
        self.updateCart(product: model, barId: bar.id.value, shouldAdd: false, bar: bar)
    }
    
    func productMenuCell(cell: ProductMenuCell, addToCartButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let bar = self.searchResults[indexPath.section].bar
        let product = self.searchResults[indexPath.section].products[indexPath.row]
        
        if product.haveModifiers.value {
            let productModifiersNavigation = (self.storyboard!.instantiateViewController(withIdentifier: "ProductModifiersNavigation") as! UINavigationController)
            productModifiersNavigation.modalPresentationStyle = .fullScreen
            
            let productModifiersController = (productModifiersNavigation.viewControllers.first as! ProductModfiersViewController)
            productModifiersController.productInfo = (id: product.id.value,
                                                      name: product.name.value,
                                                      price: Double(product.price.value) ?? 0.0,
                                                      quantity: product.quantity.value)
            productModifiersController.establishmentId = bar.id.value
            productModifiersController.type = bar.menuTypeRaw.value
            productModifiersController.regionInfo = (country: bar.country.value,
                                                     currencySymbol: bar.currencySymbol.value,
                                                     currencyCode: bar.currencyCode.value)
            
            self.navigationController?.present(productModifiersNavigation, animated: true, completion: nil)
        } else {
            self.updateCart(product: product, barId: bar.id.value, shouldAdd: true, bar: bar)
        }
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
        
        var params:[String : Any] =  ["supported_order_type": SearchScope.drink.rawValue,
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
                    var products: [Product] = []
                    try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                        
                        var mutableBarDict = responseObject
                        mutableBarDict["mapping_type"] = ExploreMappingType.bars.rawValue
                        bar = try! transaction.importUniqueObject(Into<Bar>(), source: mutableBarDict)
                        
                        let productsArray = responseObject["menus"] as? [[String : Any]] ?? []
                        for menuItem in productsArray {
                            
                            let context = ProductMenuSegmentMappingContext(type: .takeAwaydelivery)
                            
                            var itemData: [String : Any] = menuItem
                            itemData["contextual_id"] = Product.getContextulId(source: menuItem,
                                                                               mapContext: context)
                            let importedFood = try! transaction.importUniqueObject(Into<Product>(), source: itemData)
                            products.append(importedFood!)
                        }
                        
//                        let productsArray = responseObject["menus"] as? [[String : Any]] ?? []
//                        products = try! transaction.importUniqueObjects(Into<Product>(), sourceArray: productsArray)
                    })
                    
                    let fetchedBar = Utility.barCodeDataStack.fetchExisting(bar)
                    var fetchedProducts: [Product] = []
                    for product in products {
                        let fetchedProduct  = Utility.barCodeDataStack.fetchExisting(product)
                        fetchedProducts.append(fetchedProduct!)
                    }
                    
                    let resultItem = ScopeSearchResult(bar: fetchedBar!, foods: fetchedProducts)
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
        
        var params:[String : Any] =  ["supported_order_type": SearchScope.drink.rawValue,
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
    
    func updateCart(product: Product, barId: String, shouldAdd: Bool, bar: Bar) {
        let previousQuantity = product.quantity.value
        Utility.shared.updateCart(product: product, shouldAdd: shouldAdd, barId: barId, shouldSeperateCards: bar.menuType == .barCode ? true : false, cart_type: "takeaway_delivery") { (error) in
            if let error = error {
                KVNProgress.showError(withStatus: error.localizedDescription)
            }
        } successCompletion: { (type) in
            
        } updateCountCompletion: { (cartItemID) in
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let editedProduct = transaction.edit(product)
                editedProduct?.quantity.value = shouldAdd ? product.quantity.value + 1 : 0
                editedProduct?.cartItemId.value = cartItemID
                
                product.isAddingToCart = false
                product.isRemovingFromCart = false

                let cartInfo: ProductCartUpdatedObject = (product: editedProduct!, newQuantity: editedProduct!.quantity.value, previousQuantity: previousQuantity, barId: barId)
                let cartDic: [String:Any] = [
                    "product": editedProduct!,
                    "newQuantity": editedProduct!.quantity.value,
                    "previousQuantity": previousQuantity,
                    "barId": barId,
                    "cartType": "takeaway_delivery"
                ]
                NotificationCenter.default.post(name: notificationNameProductCartUpdated, object: cartInfo, userInfo: cartDic)
            })
        }
        
        self.statefulTableView.innerTable.reloadData()
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
    @objc func productCartUpdatedNotification(notification: Notification) {
        self.statefulTableView.innerTable.reloadData()
    }
    
    @objc func myCartUpdatedNotification(notification: Notification) {
        self.statefulTableView.innerTable.reloadData()
    }
}
