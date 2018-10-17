//
//  ExploreDealViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 27/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import SJSegmentedScrollView
import CoreStore
import Alamofire
import ObjectMapper

protocol ExploreDetailDealsViewControllerDelegate: class {
    func exploreDealsController(controller: ExploreDetailDealsViewController, didSelectRowAt deal: Deal)
}

class ExploreDetailDealsViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!

    weak var delegate: ExploreDetailDealsViewControllerDelegate!
    
    var deals: [Deal] = []
    var explore : Explore!
    
    var dealsRequest: DataRequest?
    var dealsLoadMore = Pagination()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setUpStatefulTableView()
        self.statefulTableView.triggerInitialLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        self.statefulTableView.innerTable.estimatedRowHeight = 250.0
        self.statefulTableView.innerTable.tableFooterView = UIView()
        self.statefulTableView.innerTable.separatorStyle = .none
        
        self.statefulTableView.innerTable.register(cellType: DealTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension ExploreDetailDealsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.deals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: DealTableViewCell.self)
        cell.setUpDealCell(deal: self.deals[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        self.delegate.exploreDealsController(controller: self, didSelectRowAt: self.deals[indexPath.row])
    }
}

//MARK: SJSegmentedViewControllerViewSource
extension ExploreDetailDealsViewController: SJSegmentedViewControllerViewSource {
    func viewForSegmentControllerToObserveContentOffsetChange() -> UIView {
        return self.statefulTableView.innerTable
    }
}

extension ExploreDetailDealsViewController {
    func getDeals(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.dealsLoadMore = Pagination()
        }
        
        let params: [String : Any] = ["establishment_id": self.explore.id.value,
                                      "type" : "live",
                                      "pagination" : true,
                                      "page": self.dealsLoadMore.next]
        
        self.dealsLoadMore.isLoading = true
        self.dealsRequest = APIHelper.shared.hitApi(params: params, apiPath: apioffer, method: .get) { (response, serverError, error) in
            
            self.dealsLoadMore.isLoading = false
            
            guard error == nil else {
                self.dealsLoadMore.error = error! as NSError
                self.statefulTableView.reloadData()
                completion(error! as NSError)
                return
            }
            
            guard serverError == nil else {
                self.dealsLoadMore.error = serverError!.nsError()
                self.statefulTableView.reloadData()
                completion(serverError!.nsError())
                return
            }
            
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseArray = (responseDict?["data"] as? [[String : Any]]) {
                
                if isRefreshing {
                    self.deals.removeAll()
                }
                
////                var responseDeals: [Deal] = []
//                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
//
//                    let ids = try! transaction.importUniqueObjects(Into<Deal>(), sourceArray: responseArray)
//
//                    let fetchedDeals = transaction.fetchAll(From<Deal>(), Where<Deal>("%K in %@", Deal.uniqueIDKeyPath, ids))
//                    if let fetchedDeals = fetchedDeals, !fetchedDeals.isEmpty {
//                        self.deals.append(contentsOf: fetchedDeals)
//                    }
//                })
                
                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                    let deals = try! transaction.importUniqueObjects(Into<Deal>(), sourceArray: responseArray)
                    
                    if !deals.isEmpty {
                        let ids = deals.map{$0.uniqueIDValue}
                        transaction.deleteAll(From<Deal>(), Where<Deal>("NOT(%K in %@)", Deal.uniqueIDKeyPath, ids))
                    }
                })
                
                self.deals.append(contentsOf: Utility.inMemoryStack.fetchAll(From<Deal>()) ?? [])
                
                self.dealsLoadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                self.statefulTableView.canLoadMore = self.dealsLoadMore.canLoadMore()
                self.statefulTableView.innerTable.reloadData()
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
}

extension ExploreDetailDealsViewController: StatefulTableDelegate {
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getDeals(isRefreshing: false) { [unowned self] (error) in
            debugPrint("deal== \(self.deals.count)")
            handler(self.deals.count == 0, error)
        }
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.dealsLoadMore.error = nil
        tvc.innerTable.reloadData()
        self.getDeals(isRefreshing: false) { [unowned self] (error) in
            handler(self.dealsLoadMore.canLoadMore(), error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getDeals(isRefreshing: true) { [unowned self] (error) in
            handler(self.deals.count == 0, error)
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
            let title = "No Deals Available"
            let subTitle = "Tap to reload"
            
            let emptyDataView = EmptyDataView.loadFromNib()
            emptyDataView.setTitle(title: title, desc: subTitle, iconImageName: "icon_loading", buttonTitle: "Reload")
            
            emptyDataView.actionHandler = { (sender: UIButton) in
                tvc.triggerInitialLoad()
            }
            
            return emptyDataView
            
        } else {
            let initialErrorView = LoadingAndErrorView.loadFromNib()
            initialErrorView.showErrorView(canRetry: true)
            initialErrorView.backgroundColor = .clear
            initialErrorView.showErrorViewWithRetry(errorMessage: forInitialLoadError!.localizedDescription, reloadMessage: "Tap to reload")
            
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
            loadingView.showErrorViewWithRetry(errorMessage: forLoadMoreError!.localizedDescription, reloadMessage: "Tap to reload")
        }
        
        loadingView.retryHandler = {(sender: UIButton) in
            tvc.triggerLoadMore()
        }
        
        return loadingView
    }
}
