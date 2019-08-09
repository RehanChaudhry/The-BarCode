//
//  FoodSearchViewController.swift
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

class FoodSearchViewController: BaseSearchScopeViewController {

    var searchResults: [ScopeSearchResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    //MARK: My Methods
    override func setUpStatefulTableView() {
        super.setUpStatefulTableView()
        
        self.statefulTableView.innerTable.tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.statefulTableView.frame.size.width, height: 16.0))
        self.statefulTableView.innerTable.register(headerFooterViewType: ScopeSearchResultHeaderView.self)
        self.statefulTableView.innerTable.register(cellType: FoodMenuCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
    }
    
    override func prepareToReset() {
        super.prepareToReset()
        
        self.dataRequest?.cancel()
        self.resetCurrentData()
    }
    
    override func reset() {
        super.reset()
        
        self.prepareToReset()
        self.statefulTableView.triggerInitialLoad()
    }
    
    override func resetCurrentData() {
        super.resetCurrentData()
        
        self.searchResults.removeAll()
        self.statefulTableView.innerTable.reloadData()
    }

    func setUpMarkers() {
        self.mapView.clear()
        self.markers.removeAll()
        
        var bounds = GMSCoordinateBounds()
        for (index, result) in self.searchResults.enumerated() {
            
            let bar = result.bar
            let location: CLLocation = CLLocation(latitude: CLLocationDegrees(bar.latitude.value), longitude: CLLocationDegrees(bar.longitude.value))
            
            bounds = bounds.includingCoordinate(location.coordinate)
            
            let pinImage = self.getPinImage(explore: bar)
            let marker = self.createMapMarker(location: location, pinImage: pinImage)
            marker.userData = bar
            marker.zIndex = Int32(index)
            marker.map = self.mapView
            
            self.markers.append(marker)
        }
        
    }
    
    func getPinImage(explore: Bar) -> UIImage {
        var pinImage = UIImage(named: "icon_pin_gold")!
        if let timings = explore.timings.value {
            if timings.dayStatus == .opened {
                if timings.isOpen.value {
                    if let activeStandardOffer = explore.activeStandardOffer.value {
                        pinImage = Utility.shared.getPinImage(offerType: activeStandardOffer.type)
                    } else {
                        pinImage = UIImage(named: "icon_pin_grayed")!
                    }
                } else {
                    pinImage = UIImage(named: "icon_pin_grayed")!
                }
            } else {
                pinImage = UIImage(named: "icon_pin_grayed")!
            }
            
        } else {
            pinImage = UIImage(named: "icon_pin_grayed")!
        }
        
        return pinImage
    }
    
    func createMapMarker(location: CLLocation, pinImage: UIImage) -> GMSMarker {
        let marker = GMSMarker(position: location.coordinate)
        let iconImage = pinImage
        let markerView = UIImageView(image: iconImage)
        marker.iconView = markerView
        return marker
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension FoodSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.searchResults.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults[section].foods.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = self.statefulTableView.innerTable.dequeueReusableHeaderFooterView(ScopeSearchResultHeaderView.self)
        headerView?.setUpCell(explore: self.searchResults[section].bar)
        headerView?.delegate = self
        headerView?.section = section
        return headerView
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: FoodMenuCell.self)
        let food = self.searchResults[indexPath.section].foods[indexPath.row]
        cell.setupCellForFood(food: food)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let bar = self.searchResults[indexPath.section].bar
        self.moveToBarDetails(barId: bar.id.value, scopeType: .food)
    }
}

//MARK: ScopeSearchResultHeaderViewDelegate
extension FoodSearchViewController: ScopeSearchResultHeaderViewDelegate {
    func scopeSearchResultHeaderView(headerView: ScopeSearchResultHeaderView, detailsButtonTapped sender: UIButton) {
        let bar = self.searchResults[headerView.section].bar
        self.moveToBarDetails(barId: bar.id.value, scopeType: .food)
    }
}

//MARK: Webservices Methods
extension FoodSearchViewController {
    
    func getBars(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        self.dataRequest?.cancel()
        
        var params:[String : Any] =  ["type": SearchScope.food.rawValue,
                                      "pagination" : true,
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
        
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathMenu, method: .get) { (response, serverError, error) in
            
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
                    var foods: [Food] = []
                    try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                        
                        var mutableBarDict = responseObject
                        mutableBarDict["mapping_type"] = ExploreMappingType.bars.rawValue
                        bar = try! transaction.importUniqueObject(Into<Bar>(), source: mutableBarDict)
                        
                        let foodsArray = responseObject["menus"] as? [[String : Any]] ?? []
                        foods = try! transaction.importUniqueObjects(Into<Food>(), sourceArray: foodsArray)
                    })
                    
                    let fetchedBar = Utility.inMemoryStack.fetchExisting(bar)
                    var fetchedFoods: [Food] = []
                    for food in foods {
                        let fetchedFood  = Utility.inMemoryStack.fetchExisting(food)
                        fetchedFoods.append(fetchedFood!)
                    }
                    
                    let resultItem = ScopeSearchResult(bar: fetchedBar!, foods: fetchedFoods)
                    self.searchResults.append(resultItem)
                }
                
                self.loadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                self.statefulTableView.canLoadMore = self.loadMore.canLoadMore()
                
                self.statefulTableView.innerTable.reloadData()
                self.setUpMarkers()
                
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
        
        try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
            if let bars = transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), bar.id.value)) {
                for bar in bars {
                    bar.isUserFavourite.value = !bar.isUserFavourite.value
                }
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
extension FoodSearchViewController: StatefulTableDelegate {
    
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
            let title = "No Search Result Found"
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
