//
//  LiveOffersViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import CoreStore
import Alamofire
import ObjectMapper
import StatefulTableView
import GoogleMaps

protocol BarsWithLiveOffersViewControllerDelegate: class {
    func liveOffersController(controller: BarsWithLiveOffersViewController, didSelectLiveOfferOf bar: Bar)
    func liveOffersController(controller: BarsWithLiveOffersViewController, refreshSnackBar snack: SnackbarView)
    func liveOffersController(controller: BarsWithLiveOffersViewController, searchButtonTapped sender: UIButton)
    func liveOffersController(controller: BarsWithLiveOffersViewController, preferencesButtonTapped sender: UIButton)
}

class BarsWithLiveOffersViewController: ExploreBaseViewController {

    weak var delegate: BarsWithLiveOffersViewControllerDelegate!
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
        
        self.statefulTableView.innerTable.register(cellType: LiveOfferTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
    }

    //MARK: My IBActions
    @IBAction func searchButtonTapped(sender: UIButton) {
        self.delegate.liveOffersController(controller: self, searchButtonTapped: sender)
    }
    
    @IBAction func prefencesButtonTapped(sender: UIButton) {
        self.delegate.liveOffersController(controller: self, preferencesButtonTapped: sender)
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension BarsWithLiveOffersViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: LiveOfferTableViewCell.self)
        cell.delegate = self
        let bar = self.isSearching
            ? self.filteredBars[indexPath.row]
            : self.bars[indexPath.row]
        
        cell.setUpCell(explore: bar)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        let bar = self.isSearching ? self.filteredBars[indexPath.row]
            : self.bars[indexPath.row]
        
        self.delegate.liveOffersController(controller: self, didSelectLiveOfferOf: bar)
    }
}

//MARK: UISearchBarDelegate
extension BarsWithLiveOffersViewController: UISearchBarDelegate {
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
extension BarsWithLiveOffersViewController {
    func getBars(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing && !self.isSearching {
            self.loadMore = Pagination()
        }
        
        var params:[String : Any] =  ["type": ExploreType.liveOffers.rawValue]
        
        if self.isSearching {
            params["pagination"] = false
            params["keyword"] = self.searchText
            
        } else {
            params["pagination"] = true
            params["page"] = self.loadMore.next
        }
        
        self.loadMore.isLoading = true

        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiEstablishment, method: .get) { (response, serverError, error) in
            
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
                        object["mapping_type"] = ExploreMappingType.liveOffers.rawValue
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
                
                self.statefulTableView.canPullToRefresh = true
                self.statefulTableView.innerTable.reloadData()
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

extension BarsWithLiveOffersViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        
        if self.isClearingSearch {
            self.isClearingSearch = false
            handler(self.bars.count == 0, nil)
        } else {
            let refreshing = self.isSearching ? false : true
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
        
        self.delegate.liveOffersController(controller: self, refreshSnackBar: self.snackBar)
        self.getBars(isRefreshing: true) { [unowned self] (error) in
           // handler(self.bars.count == 0, error)
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
            let title = isSearching ? "No Search Result Found" : "No Live Offers Available"
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

extension BarsWithLiveOffersViewController  {
    
    override func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let bar = marker.userData as! Bar
        self.delegate.liveOffersController(controller: self, didSelectLiveOfferOf: bar)
        return false
    }
}

//LiveOfferTableViewCell
extension BarsWithLiveOffersViewController: LiveOfferTableViewCellDelegate {
    func liveOfferCell(cell: LiveOfferTableViewCell, shareButtonTapped sender: UIButton) {
        
    }
    
    func liveOfferCell(cell: LiveOfferTableViewCell, distanceButtonTapped sender: UIButton) {
        let indexPath = self.statefulTableView.innerTable.indexPath(for: cell)
        if let indexPath = indexPath {
            let bar = self.bars[indexPath.row]
            self.showDirection(bar: bar)
        }
    }
}

