//
//  BarsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import Reusable
import CoreStore
import Alamofire
import ObjectMapper
import HTTPStatusCodes
import GoogleMaps
import FirebaseAnalytics
import PureLayout

protocol BarsViewControllerDelegate: class {
    func barsController(controller: BarsViewController, didSelectBar barId: String)
    func barsController(controller: BarsViewController, didSelectBar bar: Bar)
    func barsController(controller: BarsViewController, searchButtonTapped sender: UIButton)
    func barsController(controller: BarsViewController, refreshSnackBar snack: SnackBarInfoView)
    func barsController(controller: BarsViewController, preferncesButtonTapped sender: UIButton)
    func barsController(controller: BarsViewController, standardOfferButtonTapped sender: UIButton)
}

class BarsViewController: ExploreBaseViewController {
    
    weak var delegate: BarsViewControllerDelegate!
    var isClearingSearch: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.searchBar.delegate = self
        self.statefulTableView.triggerInitialLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.statefulTableView.innerTable.reloadData()
        
        if !self.mapApiState.isLoading {
            self.setUpBasicMapBars()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: My Methods
    override func setUpStatefulTableView() {
        super.setUpStatefulTableView()
        
        self.statefulTableView.innerTable.register(cellType: BarTableViewCell.self)        
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
    }
    
    override func setUpBasicMapBars() {
        
        super.setUpBasicMapBars()
        
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
    
    //MARK: My IBActions
    @IBAction func searchButtonTapped(sender: UIButton) {
        self.delegate.barsController(controller: self, searchButtonTapped: sender)
    }
    
    @IBAction func preferenceButtonTapped(sender: UIButton) {
        Analytics.logEvent(preferenceFilterClick, parameters: nil)
        self.delegate.barsController(controller: self, preferncesButtonTapped: sender)
    }
    
    @IBAction func standardOffersButtonTapped(sender: UIButton) {
        Analytics.logEvent(standardOfferFilterClick, parameters: nil)
        self.delegate.barsController(controller: self, standardOfferButtonTapped: sender)
    }
    
    @IBAction func mapRetryButtonTapped(sender: UIButton) {
        self.setUpBasicMapBars()
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension BarsViewController: UITableViewDataSource, UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.filteredBars.count
        }
        return self.bars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: BarTableViewCell.self)
        cell.delegate = self
        cell.exploreBaseDelegate = self
       
        let bar = self.isSearching
                    ? self.filteredBars[indexPath.row]
                    : self.bars[indexPath.row]
        
        cell.setUpCell(bar: bar)
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
        Analytics.logEvent(barClickFromExplore, parameters: nil)
        
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
       
        let bar = self.isSearching ? self.filteredBars[indexPath.row]
                    : self.bars[indexPath.row]

        self.delegate.barsController(controller: self, didSelectBar: bar)
    }
}

//MARK: ExploreBaseTableViewCellDelegate
extension BarsViewController: ExploreBaseTableViewCellDelegate {
    func exploreBaseTableViewCell(cell: ExploreBaseTableViewCell, didSelectItem itemIndexPath: IndexPath) {
        guard let tableCellIndexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let bar = self.isSearching ? self.filteredBars[tableCellIndexPath.row]
            : self.bars[tableCellIndexPath.row]
        self.delegate.barsController(controller: self, didSelectBar: bar)
    }
}

//MARK: UISearchBarDelegate
extension BarsViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if searchBar.text == "" {
            self.resetSearchBar()
        } else {
            self.isSearching = true
            self.filteredBars.removeAll()
            self.statefulTableView.innerTable.reloadData()
            self.searchText = searchBar.text!
            self.statefulTableView.triggerInitialLoad()
        }
    }
 
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text == "" {
            searchBar.resignFirstResponder()
            self.resetSearchBar()
        }
    }
    
    func resetSearchBar() {
        self.isSearching = false
        self.statefulTableView.innerTable.reloadData()
        self.isClearingSearch = true
        self.statefulTableView.triggerInitialLoad()
    }
}

//MARK: Webservices Methods
extension BarsViewController {
    func getBars(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {

        if isRefreshing && !self.isSearching {
            self.loadMore = Pagination()
        }
        
        var params:[String : Any] =  ["type": ExploreType.bars.rawValue,
                                      "is_for_map" : false]

        if self.isSearching {
            params["pagination"] = false
            params["keyword"] = self.searchText
            
        } else {
            params["pagination"] = true
            params["page"] = self.loadMore.next
        }
        
        self.loadMore.isLoading = true
        
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiEstablishment, method: .get) { (response, serverError, error) in
            
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
               
                if self.isSearching {
                    self.filteredBars.removeAll()
                } else if isRefreshing {
                    self.bars.removeAll()
                }

                var importedObjects: [Bar] = []
                try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                    for responseDict in responseArray {
                        var object = responseDict
                        object["mapping_type"] = ExploreMappingType.bars.rawValue
                        let importedObject = try! transaction.importObject(Into<Bar>(), source: object)
                        importedObjects.append(importedObject!)
                    }
                })
                
                var resultBars: [Bar] = []
                for object in importedObjects {
                    let fetchedObject = Utility.barCodeDataStack.fetchExisting(object)
                    resultBars.append(fetchedObject!)
                }

                if self.isSearching {
                    self.filteredBars = resultBars
                    self.statefulTableView.canLoadMore = false
                } else {
                    self.bars.append(contentsOf: resultBars)
                    self.loadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                    self.statefulTableView.canLoadMore = self.loadMore.canLoadMore()
                }

                self.statefulTableView.innerTable.reloadData()
                self.statefulTableView.canPullToRefresh = true
                self.statefulTableView.innerTable.reloadData()
                
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
    
    func getBarsForMap(completion: @escaping (_ error: NSError?) -> Void) {

        let params:[String : Any] =  ["type": ExploreType.bars.rawValue,
                                      "pagination" : false,
                                      "is_for_map" : true]
        
        self.mapDataRequest?.cancel()
        self.mapApiState.isLoading = true
        
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiEstablishment, method: .get) { (response, serverError, error) in
            
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

extension BarsViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        
        if self.isClearingSearch {
            self.isClearingSearch = false
            handler(self.bars.count == 0, nil)
        } else {
            let refreshing  = self.isSearching ? false : true
            self.getBars(isRefreshing: refreshing) {  [unowned self] (error) in
                // handler(self.bars.count == 0, error)
                if self.isSearching {
                    handler(self.filteredBars.count == 0, error)
                } else {
                    handler(self.bars.count == 0, error)
                }
            }
        }
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.loadMore.error = nil
        tvc.innerTable.reloadData()
        
        self.getBars(isRefreshing: false) { [unowned self] (error) in
            handler(self.loadMore.canLoadMore(), error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        
        self.setUpBasicMapBars()
        self.delegate.barsController(controller: self, refreshSnackBar: self.snackBar)
        self.getBars(isRefreshing: true) { [unowned self] (error) in
            if self.isSearching {
                handler(self.filteredBars.count == 0, error)

            } else {
                handler(self.bars.count == 0, error)
            }
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
            let title = isSearching ? "No Search Result Found" : "No Bars Available"
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

extension BarsViewController: BarTableViewCellDelegare {
    func barTableViewCell(cell: BarTableViewCell, favouriteButton sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }

        let bar = self.isSearching ? self.filteredBars[indexPath.row] : self.bars[indexPath.row]
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

//MARK: MapPinsViewController
extension BarsViewController: MapPinsViewControllerDelegate {
    func mapPinsViewController(controller: MapPinsViewController, didSelectMapBar mapBar: MapBasicBar) {
        controller.dismiss(animated: true) {
            self.delegate.barsController(controller: self, didSelectBar: mapBar.barId)
        }
    }
}

extension BarsViewController  {
    override func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return super.mapView(mapView, didTap: marker)
    }
}

extension BarsViewController {
    override func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        return super.clusterManager(clusterManager, didTap: cluster)
    }
    
    override func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        
        if let mapbar = clusterItem as? MapBasicBar {
            
            let selectedBarLocation = CLLocation(latitude: mapbar.latitude, longitude: mapbar.longitude)
            
            let filteredBars = self.mapBars.filter { (bar) -> Bool in
                let location = CLLocation(latitude: bar.latitude, longitude: bar.longitude)
                return location.distance(from: selectedBarLocation) < 10.0
            }
            
            if filteredBars.count > 1 {
                let mapPinsController = self.storyboard!.instantiateViewController(withIdentifier: "MapPinsViewController") as! MapPinsViewController
                mapPinsController.mapBars = filteredBars
                mapPinsController.delegate = self
                mapPinsController.modalPresentationStyle = .overCurrentContext
                mapPinsController.modalTransitionStyle = .crossDissolve
                self.present(mapPinsController, animated: true, completion: nil)
                
                //Needs little offset to be perfectly in center b/c of other views
                let adjustedCenterPoint = mapPinsController.view.convert(self.mapContainer.center, from: self.mapContainer)
                mapPinsController.centerYConstraint.constant = adjustedCenterPoint.y - mapPinsController.view.center.y
                
            } else {
                self.delegate.barsController(controller: self, didSelectBar: mapbar.barId)
            }
        }
        return super.clusterManager(clusterManager, didTap: clusterItem)
    }
}
