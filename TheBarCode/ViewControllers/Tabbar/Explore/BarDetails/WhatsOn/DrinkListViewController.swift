//
//  DrinkListViewController.swift
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
import HTTPStatusCodes

protocol DrinkListViewControllerDelegate: class {
    func drinkListViewController(controller: DrinkListViewController, didSelect product: Product)
}

class DrinkListViewController: UIViewController {
    
    @IBOutlet var statefulTableView: StatefulTableView!
    
    weak var delegate: DrinkListViewControllerDelegate!
    
    var segments: [ProductMenuSegment] = []
    var bar : Bar!
    
    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.setUpStatefulTableView()
        self.reset()
        
        NotificationCenter.default.addObserver(self, selector: #selector(productCartUpdatedNotification(notification:)), name: notificationNameProductCartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myCartUpdatedNotification(notification:)), name: notificationNameMyCartUpdated, object: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameProductCartUpdated, object: nil)
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
        
        self.statefulTableView.innerTable.register(headerFooterViewType: ProductMenuHeaderView.self)
        self.statefulTableView.innerTable.register(cellType: ProductMenuCell.self)
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
extension DrinkListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(ProductMenuHeaderView.self)
        headerView?.setupHeader(title: self.segments[section].name, isExpanded: true)
        headerView?.delegate = self
        headerView?.section = section
        return headerView
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.segments.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let segment = self.segments[section]
        return segment.products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: ProductMenuCell.self)
        
        let segment = self.segments[indexPath.section]
        cell.setupCell(product: segment.products[indexPath.row], bar: self.bar)
        
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let segment = self.segments[indexPath.section]
        let product = segment.products[indexPath.row]
        
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        self.delegate.drinkListViewController(controller: self, didSelect: product)
    }
}

//MARK: ProductMenuHeaderViewDelegate
extension DrinkListViewController: ProductMenuHeaderViewDelegate {
    func foodMenuHeaderView(header: ProductMenuHeaderView, titleButtonTapped sender: UIButton) {
        let segment = self.segments[header.section]
        
        //segment.isExpanded = !segment.isExpanded
        
        var indexPaths: [IndexPath] = []
        for i in 0..<self.segments[header.section].products.count {
            let indexPath = IndexPath(row: i, section: header.section)
            indexPaths.append(indexPath)
        }
        
//        if segment.isExpanded {
//            self.statefulTableView.innerTable.insertRows(at: indexPaths, with: .automatic)
//        } else {
//            self.statefulTableView.innerTable.deleteRows(at: indexPaths, with: .automatic)
//        }
        
        header.setupHeader(title: segment.name, isExpanded: true)
    }
}


//MARK: ProductMenuCellDelegate
extension DrinkListViewController: ProductMenuCellDelegate {
    func productMenuCell(cell: ProductMenuCell, selectedIndexPath: IndexPath) {
        let ProductDetailsViewController = (self.storyboard!.instantiateViewController(withIdentifier: "ProductDetailsNavigation") as! UINavigationController)
        ProductDetailsViewController.modalPresentationStyle = .fullScreen
        let product = self.segments[selectedIndexPath.section].products[selectedIndexPath.row]
        let vc = ProductDetailsViewController.viewControllers.first as! ProductDetailsViewController
        vc.productTitle = product.name.value
        vc.productDesc = product.detail.value
        vc.productImage = product.image.value
        vc.productPrice = product.price.value
        self.navigationController?.present(ProductDetailsViewController, animated: true, completion: nil)
    }
    
    func productMenuCell(cell: ProductMenuCell, removeFromCartButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let model = self.segments[indexPath.section].products[indexPath.row]
        self.updateCart(product: model, shouldAdd: false)
    }
    
    func productMenuCell(cell: ProductMenuCell, addToCartButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let product = self.segments[indexPath.section].products[indexPath.row]
        
        if product.haveModifiers.value {
            let productModifiersNavigation = (self.storyboard!.instantiateViewController(withIdentifier: "ProductModifiersNavigation") as! UINavigationController)
            productModifiersNavigation.modalPresentationStyle = .fullScreen
            
            let productModifiersController = (productModifiersNavigation.viewControllers.first as! ProductModfiersViewController)
            productModifiersController.delegate = self
            productModifiersController.productInfo = (id: product.id.value,
                                                      name: product.name.value,
                                                      price: Double(product.price.value) ?? 0.0,
                                                      quantity: product.quantity.value)
            productModifiersController.establishmentId = self.bar.id.value
            productModifiersController.type = self.bar.menuTypeRaw.value
            productModifiersController.regionInfo = (country: self.bar.country.value,
                                                     currencySymbol: self.bar.currencySymbol.value,
                                                     currencyCode: self.bar.currencyCode.value)
            productModifiersController.cartType = "takeaway_delivery"
            productModifiersController.isSeperateCart = self.bar.menuType == .barCode ? true : false
            
            self.navigationController?.present(productModifiersNavigation, animated: true, completion: nil)
        } else {
            self.updateCart(product: product, shouldAdd: true)
        }
    }
}

//MARK: Webservices Methods
extension DrinkListViewController {
    func getDeals(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.loadMore = Pagination()
        }
        
        let params: [String : Any] = ["establishment_id": self.bar.id.value,
                                      "supported_order_type" : "takeaway_delivery",
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
                
                let mapContext = ProductMenuSegmentMappingContext(type: .takeAwaydelivery)
                
                let segments = Mapper<ProductMenuSegment>(context: mapContext).mapArray(JSONArray: segmentsWithItems)
                self.segments.append(contentsOf: segments)
                
                segments.first?.isExpanded = true
                
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
    
    func updateCart(product: Product, shouldAdd: Bool) {
        let previousQuantity = product.quantity.value
        Utility.shared.updateCart(product: product, shouldAdd: shouldAdd, barId: self.bar.id.value, shouldSeperateCards: self.bar.menuType == .barCode ? true : false, cart_type: "takeaway_delivery") { (error) in
            if let error = error {
                KVNProgress.showError(withStatus: error.localizedDescription)
                
                let shouldRefresh = error.userInfo["refresh"] as? Bool
                if error.code == HTTPStatusCode.notAcceptable.rawValue, shouldRefresh == true {
                    self.reset()
                }
            }
        } successCompletion: { (type) in
            if type == "takeaway_delivery" {
                self.statefulTableView.innerTable.reloadData()
            }
        } updateCountCompletion: { (cartItemID) in
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let editedProduct = transaction.edit(product)
                editedProduct?.quantity.value = shouldAdd ? product.quantity.value + 1 : 0
                editedProduct?.cartItemId.value = cartItemID
                
                product.isAddingToCart = false
                product.isRemovingFromCart = false

                let cartInfo: ProductCartUpdatedObject = (product: editedProduct!, newQuantity: editedProduct!.quantity.value, previousQuantity: previousQuantity, barId: self.bar.id.value)
                let cartDic: [String:Any] = [
                    "product": editedProduct!,
                    "newQuantity": editedProduct!.quantity.value,
                    "previousQuantity": previousQuantity,
                    "barId": self.bar.id.value,
                    "cartType": "takeaway_delivery"
                ]
                NotificationCenter.default.post(name: notificationNameProductCartUpdated, object: cartInfo, userInfo: cartDic)
            })
        }
    }
}

//MARK: ProductModfiersViewControllerDelegate
extension DrinkListViewController: ProductModfiersViewControllerDelegate {
    func productModfiersViewController(controller: ProductModfiersViewController, cartUpdateFailed error: NSError) {
        let shouldRefresh = error.userInfo["refresh"] as? Bool
        if error.code == HTTPStatusCode.notAcceptable.rawValue, shouldRefresh == true {
            self.dismiss(animated: true) {
                self.reset()
            }
        }
    }
}

//MARK: StatefulTableDelegate
extension DrinkListViewController: StatefulTableDelegate {
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getDeals(isRefreshing: false) { [unowned self] (error) in
            debugPrint("Drink menu segments == \(self.segments.count)")
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
            let title = "No Drinks Available"
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
extension DrinkListViewController {
    @objc func productCartUpdatedNotification(notification: Notification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let cartType = dict["cartType"] as? String {
                if cartType == "takeaway_delivery" {
                    self.statefulTableView.innerTable.reloadData()
                }
            }
        }
    }
    
    @objc func myCartUpdatedNotification(notification: Notification) {
        self.getDeals(isRefreshing: true) { [unowned self] (error) in
            debugPrint("food segments== \(self.segments.count)")
        }
    }
}
