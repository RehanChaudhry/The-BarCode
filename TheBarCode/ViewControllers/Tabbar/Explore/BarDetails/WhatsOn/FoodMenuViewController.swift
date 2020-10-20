//
//  FoodMenuViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 16/07/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import SJSegmentedScrollView
import CoreStore
import Alamofire
import ObjectMapper
import PureLayout
import FirebaseAnalytics
import KVNProgress

protocol FoodMenuViewControllerDelegate: class {
    func foodMenuViewController(controller: FoodMenuViewController, didSelect food: Food)
}

class FoodMenuViewController: UIViewController {
    
    @IBOutlet var statefulTableView: StatefulTableView!
    
    weak var delegate: FoodMenuViewControllerDelegate!
    
    var segments: [FoodMenuSegment] = []
//    var foods: [Food] = []
    var bar : Bar!
    
    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.setUpStatefulTableView()
        self.reset()
        
        NotificationCenter.default.addObserver(self, selector: #selector(foodCartUpdatedNotification(notification:)), name: notificationNameFoodCartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myCartUpdatedNotification(notification:)), name: notificationNameMyCartUpdated, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameFoodCartUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameMyCartUpdated, object: nil)
    }
    
    //MARK: My Methods
    
    func reset() {
        self.dataRequest?.cancel()
        self.loadMore = Pagination()
        self.segments.removeAll()
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
        self.statefulTableView.innerTable.separatorInset = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 0.0, right: 16.0)
        
        let tableHeader = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: 8.0))
        self.statefulTableView.innerTable.tableHeaderView = tableHeader
        
        self.statefulTableView.innerTable.register(headerFooterViewType: FoodMenuHeaderView.self)
        self.statefulTableView.innerTable.register(cellType: FoodMenuCell.self)
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
extension FoodMenuViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(FoodMenuHeaderView.self)
        headerView?.setupHeader(title: self.segments[section].name)
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.segments.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let segment = self.segments[section]
        return segment.foods.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: FoodMenuCell.self)
        
        let segment = self.segments[indexPath.section]
        cell.setupCellForFood(food: segment.foods[indexPath.row], isInAppPaymentOn: self.bar.isInAppPaymentOn.value)
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let segment = self.segments[indexPath.section]
        let food = segment.foods[indexPath.row]
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        self.delegate.foodMenuViewController(controller: self, didSelect: food)
    }
}

//MARK: FoodMenuCellDelegate
extension FoodMenuViewController: FoodMenuCellDelegate {
    func foodMenuCell(cell: FoodMenuCell, removeFromCartButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let model = self.segments[indexPath.section].foods[indexPath.row]
        self.updateCart(food: model, shouldAdd: false)
    }
    
    func foodMenuCell(cell: FoodMenuCell, addToCartButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let model = self.segments[indexPath.section].foods[indexPath.row]
        self.updateCart(food: model, shouldAdd: true)
    }
}

//MARK: Webservices Methods
extension FoodMenuViewController {
    func getDeals(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.loadMore = Pagination()
        }
        
        let params: [String : Any] = ["establishment_id": self.bar.id.value,
                                      "type" : "food",
                                      "pagination" : true,
                                      "page": self.loadMore.next]
        
        self.loadMore.isLoading = true
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathMenuSegments, method: .get) { (response, serverError, error) in
            
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
                    self.segments.removeAll()
                }
                
                let segmentsWithItems = responseArray.filter({ (dict) -> Bool in
                    if let items = dict["items"] as? [[String : Any]], items.count > 0 {
                        return true
                    } else {
                        return false
                    }
                })
                
                let segments = Mapper<FoodMenuSegment>().mapArray(JSONArray: segmentsWithItems)
                self.segments.append(contentsOf: segments)
                
                if let pagination = responseDict?["pagination"] as? [String : Any] {
                    self.loadMore = Mapper<Pagination>().map(JSON: pagination)!
                }
                
                self.statefulTableView.canLoadMore = self.loadMore.canLoadMore()
                self.statefulTableView.innerTable.reloadData()
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
    
    func updateCart(food: Food, shouldAdd: Bool) {
        
        var params: [String : Any] = ["id" : food.id.value,
                                      "establishment_id" : self.bar.id.value]
        if shouldAdd {
            food.isAddingToCart = true
            params["quantity"] = food.quantity.value + 1
        } else {
            food.isRemovingFromCart = true
            params["quantity"] = 0
        }
        
        self.statefulTableView.innerTable.reloadData()
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathCart, method: .post) { (response, serverError, error) in
            
            let previousQuantity = food.quantity.value
            
            defer {
                food.isAddingToCart = false
                food.isRemovingFromCart = false

                let foodCartInfo: FoodCartUpdatedObject = (food: food, previousQuantity: previousQuantity, barId: self.bar.id.value)
                NotificationCenter.default.post(name: notificationNameFoodCartUpdated, object: foodCartInfo)
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
                let editedFood = transaction.edit(food)
                editedFood?.quantity.value = shouldAdd ? food.quantity.value + 1 : 0
            })
        }
    }
}

//MARK: StatefulTableDelegate
extension FoodMenuViewController: StatefulTableDelegate {
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getDeals(isRefreshing: false) { [unowned self] (error) in
            debugPrint("food segments== \(self.segments.count)")
            handler(self.segments.count == 0, error)
        }
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.loadMore.error = nil
        tvc.innerTable.reloadData()
        self.getDeals(isRefreshing: false) { [unowned self] (error) in
            handler(self.loadMore.canLoadMore(), error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getDeals(isRefreshing: true) { [unowned self] (error) in
            handler(self.segments.count == 0, error)
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
            let title = "No Food Available"
            let subTitle = "Tap to refresh"
            
            let emptyDataView = EmptyDataView.loadFromNib()
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
extension FoodMenuViewController {
    @objc func foodCartUpdatedNotification(notification: Notification) {
        self.statefulTableView.innerTable.reloadData()
    }
    
    @objc func myCartUpdatedNotification(notification: Notification) {
        self.statefulTableView.innerTable.reloadData()
    }
}


