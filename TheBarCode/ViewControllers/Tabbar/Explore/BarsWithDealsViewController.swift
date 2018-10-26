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

protocol BarsWithDealsViewControllerDelegate: class {
    func barsWithDealsController(controller: BarsWithDealsViewController, didSelect bar: Bar)
}

class BarsWithDealsViewController: ExploreBaseViewController {

    weak var delegate: BarsWithDealsViewControllerDelegate!
    
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
        
        self.delegate.barsWithDealsController(controller: self, didSelect: bar)
    }
}

//MARK: UISearchBarDelegate

extension BarsWithDealsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if searchBar.text == "" {
            self.searchText = searchBar.text!
            self.isSearching = false
            self.statefulTableView.innerTable.reloadData()
        } else {
            self.isSearching = true
            self.filteredBars.removeAll()
            self.statefulTableView.innerTable.reloadData()
            self.searchText = searchBar.text!
            self.statefulTableView.triggerInitialLoad()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = searchBar.text!
        self.isSearching = false
        self.statefulTableView.innerTable.reloadData()
    }
}


//MARK: Webservices Methods
extension BarsWithDealsViewController {
    func getBars(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
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
               
                if isRefreshing {
                    self.bars.removeAll()
                }
                
                if self.isSearching {
                    self.filteredBars.removeAll()
                }
                
                var importedObjects: [Bar] = []
                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                    let objects = try! transaction.importUniqueObjects(Into<Bar>(), sourceArray: responseArray)
                    importedObjects.append(contentsOf: objects)
                })
                
                var resultBars: [Bar] = []
                for object in importedObjects {
                    let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
                    resultBars.append(fetchedObject!)
                }
                
                if self.isSearching {
                    self.filteredBars = resultBars
                    self.statefulTableView.canLoadMore = false
                    self.statefulTableView.innerTable.reloadData()
                    self.statefulTableView.reloadData()
                    completion(nil)
                } else {
                    self.bars.append(contentsOf: resultBars) 
                    self.loadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                    self.statefulTableView.canLoadMore = self.loadMore.canLoadMore()
                    self.statefulTableView.canPullToRefresh = true
                    self.statefulTableView.innerTable.reloadData()
                    completion(nil)
                }
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
}

extension BarsWithDealsViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        let refreshing = self.isSearching ? false : true
        self.getBars(isRefreshing: refreshing) {  [unowned self] (error) in
            handler(self.bars.count == 0, error)
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
            
            let title = isSearching ? "No Search Result Found" : "No Bars Deals Available"
            let subTitle = "Tap to Refresh"
            
            let emptyDataView = EmptyDataView.loadFromNib()
            emptyDataView.setTitle(title: title, desc: subTitle, iconImageName: "icon_loading", buttonTitle: "Refresh")
            
            emptyDataView.actionHandler = { (sender: UIButton) in
                tvc.triggerInitialLoad()
            }
            
            return emptyDataView
            
        } else {
            let initialErrorView = LoadingAndErrorView.loadFromNib()
            initialErrorView.showErrorView(canRetry: true)
            initialErrorView.backgroundColor = .clear
            initialErrorView.showErrorViewWithRetry(errorMessage: forInitialLoadError!.localizedDescription, reloadMessage: "Tap to Refresh")
            
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
            loadingView.showErrorViewWithRetry(errorMessage: forLoadMoreError!.localizedDescription, reloadMessage: "Tap to Refresh")
        }
        
        loadingView.retryHandler = {(sender: UIButton) in
            tvc.triggerLoadMore()
        }
        
        return loadingView
    }
}






