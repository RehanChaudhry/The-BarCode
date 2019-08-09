//
//  DealsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import CoreStore
import Alamofire
import ObjectMapper
import GoogleMaps
import FirebaseAnalytics

protocol BarsWithDealsViewControllerDelegate: class {
    func barsWithDealsController(controller: BarsWithDealsViewController, didSelect bar: Bar)
    func barsWithDealsController(controller: BarsWithDealsViewController, refreshSnackBar snack: SnackbarView)
    func barsWithDealsController(controller: BarsWithDealsViewController, searchButtonTapped sender: UIButton)
    func barsWithDealsController(controller: BarsWithDealsViewController, preferncesButtonTapped sender: UIButton)
    func barsWithDealsController(controller: BarsWithDealsViewController, standardOfferButtonTapped sender: UIButton)
}

class BarsWithDealsViewController: ExploreBaseViewController {

    weak var delegate: BarsWithDealsViewControllerDelegate!
    
    var isClearingSearch: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.searchBar.delegate = self
                
        self.statefulTableView.triggerInitialLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: My Methods
    
    override func setUpStatefulTableView() {
        super.setUpStatefulTableView()
        
        self.statefulTableView.innerTable.register(cellType: DealTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
    }

    //MARK: My IBActions
    @IBAction func searchButtonTapped(sender: UIButton) {
        self.delegate.barsWithDealsController(controller: self, searchButtonTapped: sender)
    }

    @IBAction func prefencesButtonTapped(sender: UIButton) {
        Analytics.logEvent(preferenceFilterClick, parameters: nil)
        self.delegate.barsWithDealsController(controller: self, preferncesButtonTapped: sender)
    }
    
    @IBAction func standardOffersButtonTapped(sender: UIButton) {
        Analytics.logEvent(standardOfferFilterClick, parameters: nil)
        self.delegate.barsWithDealsController(controller: self, standardOfferButtonTapped: sender)
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension BarsWithDealsViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: DealTableViewCell.self)
        cell.delegate = self
        let bar = self.isSearching
            ? self.filteredBars[indexPath.row]
            : self.bars[indexPath.row]
        cell.setUpCell(explore: bar)
        cell.exploreBaseDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let aCell = cell as? DealTableViewCell {
            aCell.scrollToCurrentImage()
            
            let bar = self.bars[indexPath.row]
            let imageCount = bar.images.value.count
            
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let aCell = cell as? DealTableViewCell {
            aCell.pagerView.automaticSlidingInterval = 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        let bar = self.isSearching ? self.filteredBars[indexPath.row]
            : self.bars[indexPath.row]
        
        self.delegate.barsWithDealsController(controller: self, didSelect: bar)
    }
}

//MARK: ExploreBaseTableViewCellDelegate
extension BarsWithDealsViewController: ExploreBaseTableViewCellDelegate {
    func exploreBaseTableViewCell(cell: ExploreBaseTableViewCell, didSelectItem itemIndexPath: IndexPath) {
        guard let tableCellIndexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let bar = self.isSearching ? self.filteredBars[tableCellIndexPath.row]
            : self.bars[tableCellIndexPath.row]
        self.delegate.barsWithDealsController(controller: self, didSelect: bar)
    }
}

//MARK: UISearchBarDelegate
extension BarsWithDealsViewController: UISearchBarDelegate {
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
        self.refreshMap()
    }
}


//MARK: Webservices Methods
extension BarsWithDealsViewController {
    func getBars(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing && !self.isSearching {
            self.loadMore = Pagination()
        }
        
        var params:[String : Any] =  ["type": ExploreType.deals.rawValue]
        
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
               
                if self.isSearching {
                    self.filteredBars.removeAll()
                } else if isRefreshing {
                    self.bars.removeAll()
                }
                
                var importedObjects: [Bar] = []
                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                    for responseDict in responseArray {
                        var object = responseDict
                        object["mapping_type"] = ExploreMappingType.deals.rawValue
                        let importedObject = try! transaction.importObject(Into<Bar>(), source: object)
                        importedObjects.append(importedObject!)
                    }
                })
                
                var resultBars: [Bar] = []
                for object in importedObjects {
                    let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
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
                self.statefulTableView.reloadData()
                self.refreshMap()
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
}

extension BarsWithDealsViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        
        if self.isClearingSearch {
            self.isClearingSearch = false
            handler(self.bars.count == 0, nil)
        } else {
            let refreshing = self.isSearching ? false : true
            self.getBars(isRefreshing: refreshing) {  [unowned self] (error) in
                //handler(self.bars.count == 0, error)
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
       
        self.delegate.barsWithDealsController(controller: self, refreshSnackBar: self.snackBar)
        self.getBars(isRefreshing: true) { [unowned self] (error) in
            //handler(self.bars.count == 0, error)
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
            
            let title = isSearching ? "No Search Result Found" : "No Bars Deals Available"
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

extension BarsWithDealsViewController  {
    
    override func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let bar = marker.userData as! Bar
        self.delegate.barsWithDealsController(controller: self, didSelect: bar)
        return false
    }
}

//MARK: DealTableViewCellDelegate
extension BarsWithDealsViewController: DealTableViewCellDelegate {
    func dealTableViewCell(cell: DealTableViewCell, distanceButtonTapped sender: UIButton) {
        let indexPath = self.statefulTableView.innerTable.indexPath(for: cell)
        if let indexPath = indexPath {
            let bar = self.bars[indexPath.row]
            self.showDirection(bar: bar)
        }
    }
    
    func dealTableViewCell(cell: DealTableViewCell, bookmarkButtonTapped sender: UIButton) {
        
    }
    
}





