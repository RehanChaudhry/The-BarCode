//
//  MyCartViewController.swift
//  TheBarCode
//
//  Created by Macbook on 16/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import Alamofire
import ObjectMapper
import CoreStore

protocol MyCartViewControllerDelegate: class {
    func myCartViewController(controller: MyCartViewController, badgeCountDidUpdate count: Int)
}

class MyCartViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var barNameLabel: UILabel!
    
    @IBOutlet weak var checkOutButton: GradientButton!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
        
    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    var orders: [Order] = []
    var selectedOrder: Order? {
        didSet {
            self.setUpBadgeValue()
            self.calculateBill()
            
            if self.selectedOrder?.isClosed == true {
                self.checkOutButton.isUserInteractionEnabled = false
                self.checkOutButton.updateColor(withGrey: true)
            } else {
                self.checkOutButton.isUserInteractionEnabled = true
                self.checkOutButton.updateColor(withGrey: false)
            }
        }
    }
    
    weak var delegate: MyCartViewControllerDelegate?
    
    var inProgressRequestCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let leftbarButton = self.navigationItem.leftBarButtonItem
        leftbarButton?.image = leftbarButton?.image?.withRenderingMode(.alwaysOriginal)
        
        self.setUpStatefulTableView()
        self.reset()
        
        NotificationCenter.default.addObserver(self, selector: #selector(foodCartUpdatedNotification(notification:)), name: notificationNameFoodCartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(drinkCartUpdatedNotification(notification:)), name: notificationNameDrinkCartUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(myCartUpdatedNotification(notification:)), name: notificationNameMyCartUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameDrinkCartUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameFoodCartUpdated, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameMyCartUpdated, object: nil)
    }
    
    //MARK: My Methods
    func setUpStatefulTableView() {
        
        self.statefulTableView.innerTable.register(cellType: OrderItemTableViewCell.self)
        self.statefulTableView.innerTable.register(headerFooterViewType: CartSectionHeaderView.self)

        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        
        self.statefulTableView.backgroundColor = .clear
        for aView in self.statefulTableView.subviews {
            aView.backgroundColor = .clear
        }
        
        self.statefulTableView.canLoadMore = false
        self.statefulTableView.canPullToRefresh = false
        self.statefulTableView.innerTable.rowHeight = UITableViewAutomaticDimension
        self.statefulTableView.innerTable.estimatedRowHeight = 200.0
        self.statefulTableView.innerTable.tableFooterView = UIView()
        self.statefulTableView.innerTable.separatorStyle = .none
        self.statefulTableView.statefulDelegate = self
       
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 8))
        tableHeaderView.backgroundColor = UIColor.clear
        self.statefulTableView.innerTable.tableHeaderView = tableHeaderView
    }
    
    func reset() {
        self.dataRequest?.cancel()
        self.loadMore = Pagination()
        self.orders.removeAll()
        self.statefulTableView.innerTable.reloadData()
        
        self.selectedOrder = nil
        
        self.statefulTableView.canLoadMore = false
        self.statefulTableView.state = .idle
        self.statefulTableView.triggerInitialLoad()
    }
    
    func calculateBill() {
      
        if let order = self.selectedOrder {
            self.barNameLabel.text = order.barName
            
            var total: Double = 0.0
              
            for orderItem in order.orderItems {
                total += (orderItem.unitPrice * Double(orderItem.quantity))
            }
                                        
            let priceString = String(format: "%.2f", total)
            let buttonTitle = "Checkout - £ " + priceString
            
            self.checkOutButton.setTitle(buttonTitle, for: .normal)
        } else {
            self.barNameLabel.text = ""
            let buttonTitle = "Checkout - " + " N/A"
            self.checkOutButton.setTitle(buttonTitle, for: .normal)
        }
    }
    
    func setUpBadgeValue() {
        if let order = self.selectedOrder {
            var count: Int = 0
            for item in order.orderItems {
                count += item.quantity
            }
            self.tabBarController?.tabBar.items?[3].badgeValue = "\(count)"
            self.delegate?.myCartViewController(controller: self, badgeCountDidUpdate: count)
        } else {
            self.tabBarController?.tabBar.items?[3].badgeValue = nil
            self.delegate?.myCartViewController(controller: self, badgeCountDidUpdate: 0)
        }
    }
    
    //MARK: My IBActions
    @IBAction func checkOutButtonTapped(sender: UIButton) {
        
        if let order = self.selectedOrder, self.inProgressRequestCount == 0 {
            let navigation = self.storyboard!.instantiateViewController(withIdentifier: "OrderTypeNavigation") as! UINavigationController
            navigation.modalPresentationStyle = .fullScreen
            
            let controller = navigation.viewControllers.first! as! OrderTypeViewController
            controller.order = order
            
            self.present(navigation, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func closeBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension MyCartViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let order = self.orders[section]
        if order.isClosed {
            return 77.0
        } else {
            return 54.0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.orders.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders[section].orderItems.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(CartSectionHeaderView.self)
        
        let order = self.orders[section]

        let isSelected =  order.barName == self.selectedOrder?.barName
        headerView?.setupHeader(title: order.barName, isSelected: isSelected, isVenueClosed: order.isClosed)
        
        headerView?.delegate = self
        headerView?.barId =  order.barId
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: OrderItemTableViewCell.self)
        
        cell.setUpCell(orderItem: self.orders[indexPath.section].orderItems[indexPath.item])
        cell.delegate = self
        
        return cell
    }
         
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
    }
}

//MARK: OrderItemTableViewCellDelegate
extension MyCartViewController: OrderItemTableViewCellDelegate {
    func orderItemTableViewCell(cell: OrderItemTableViewCell, deleteButtonTapped sender: UIButton) {
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
             debugPrint("IndexPath not found")
             return
         }
                
        self.updateCart(indexPath: indexPath, shouldDelete: true, shouldStepUp: false)
    }
    
    func orderItemTableViewCell(cell: OrderItemTableViewCell, stepperValueChanged stepper: StepperView) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("IndexPath not found")
            return
        }
        
        let orderItem = self.orders[indexPath.section].orderItems[indexPath.row]
        self.updateCart(indexPath: indexPath, shouldDelete: false, shouldStepUp: stepper.value > orderItem.quantity)
    }
}

//MARK: Webservices Methods
extension MyCartViewController {
    func getCart(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        self.dataRequest?.cancel()
        
        if isRefreshing {
            self.loadMore.next = 1
        }
        
        let params:[String : Any] =  ["pagination" : true,
                                      "limit" : 5,
                                      "page" : self.loadMore.next]
        
        self.loadMore.isLoading = true
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathCart, method: .get) { (response, serverError, error) in
        
            self.loadMore.isLoading = false
            
            defer {
                self.statefulTableView.innerTable.reloadData()
            }
            
            if isRefreshing {
                self.orders.removeAll()
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
                
                let context = OrderMappingContext(type: .cart)
                let orders = Mapper<Order>(context: context).mapArray(JSONArray: responseArray)
                if self.orders.count == 0 && orders.count > 0 {
                    self.selectedOrder = orders.first
                }
                
                self.orders.append(contentsOf: orders)
                
                self.loadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                self.statefulTableView.canLoadMore = self.loadMore.canLoadMore()
                self.statefulTableView.canPullToRefresh = true
                self.statefulTableView.innerTable.reloadData()
                
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
    
    func updateCart(indexPath: IndexPath, shouldDelete: Bool, shouldStepUp: Bool) {
        
        let order: Order = self.orders[indexPath.section]
        let item: OrderItem = order.orderItems[indexPath.row]
        
        let previousQuantity = item.quantity
        
        var params: [String : Any] = ["id" : item.id]
        if !shouldDelete {
            item.isUpdating = true
            
            if shouldStepUp {
                item.quantity += 1
            } else {
                item.quantity -= 1
            }
            
            params["quantity"] = item.quantity
            
        } else {
            item.isDeleting = true
            params["quantity"] = 0
        }
        
        self.statefulTableView.innerTable.reloadData()
        self.calculateBill()
        
        self.inProgressRequestCount += 1
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathCart, method: .post) { (response, serverError, error) in
            
            defer {
                self.calculateBill()
            }
            
            self.inProgressRequestCount -= 1
            
            item.isUpdating = false
            item.isDeleting = false
            
            func resetStepperValue() {
                if !shouldDelete {
                    if shouldStepUp {
                        item.quantity -= 1
                    } else {
                        item.quantity += 1
                    }
                }
            }
            
            guard error == nil else {
                resetStepperValue()
                self.statefulTableView.innerTable.reloadData()
                return
            }
            
            guard serverError == nil else {
                resetStepperValue()
                self.statefulTableView.innerTable.reloadData()
                return
            }
            
            if !shouldDelete {
                self.statefulTableView.innerTable.reloadData()
            } else {
                if let section = self.orders.firstIndex(where: {$0 === order}),
                    let row = order.orderItems.firstIndex(where: {$0 === item}) {
                    
                    order.orderItems.remove(at: row)
                    
                    if order.orderItems.count == 0 {
                        self.orders.remove(at: section)
                        let indexSet = IndexSet(integer: section)
                        self.statefulTableView.innerTable.deleteSections(indexSet, with: .top)
                        
                        self.selectedOrder = self.orders.first
                        
                    } else {
                        let currentIndexPath = IndexPath(row: row, section: section)
                        self.statefulTableView.innerTable.deleteRows(at: [currentIndexPath], with: .top)
                    }
                    
                    //When deleting rows / section scrollview did scroll does not get called which prevents loading next page automatically
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [unowned self] in
                        if !self.loadMore.canLoadMore() && self.orders.count == 0 {
                            self.reset()
                        } else {
                            self.scrollViewDidScroll(self.statefulTableView.innerTable)
                            self.statefulTableView.innerTable.reloadData()
                        }
                    }
                    
                } else {
                    self.statefulTableView.innerTable.reloadData()
                }
            }
            
            self.setUpBadgeValue()
            
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                if let food = try! transaction.fetchOne(From<Food>(), Where(\Food.id == item.id)) {
                    let edittedFood = transaction.edit(food)
                    edittedFood?.quantity.value = item.quantity
                } else if let drink = try! transaction.fetchOne(From<Drink>(), Where(\Drink.id == item.id)) {
                    let edittedDrink = transaction.edit(drink)
                    edittedDrink?.quantity.value = item.quantity
                }
            })
            
            let object = (item: item, previousQuantity: previousQuantity, stepUp: shouldStepUp, delete: shouldDelete, barId: order.barId, controller: self)
            NotificationCenter.default.post(name: notificationNameMyCartUpdated, object: object, userInfo: nil)
        }
    }
}

//MARK: CartSectionHeaderViewDelegate
extension MyCartViewController: CartSectionHeaderViewDelegate {
    func cartSectionHeaderView(view: CartSectionHeaderView, selectedBarId: String) {
      
        let filteredOrders = self.orders.filter { (order) -> Bool in
            return order.barId == selectedBarId
        }
       
        self.selectedOrder = filteredOrders.first
        self.statefulTableView.innerTable.reloadData()
    }
}

//MARK: StatefulTableDelegate
extension MyCartViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getCart(isRefreshing: false) {  [unowned self] (error) in
            handler(self.orders.count == 0, error)
        }
        
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.getCart(isRefreshing: false) { (error) in
            handler(self.loadMore.canLoadMore(), error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getCart(isRefreshing: true) { [unowned self] (error) in
            handler(self.orders.count == 0, error)
        }
    }
    
    func statefulTableViewViewForInitialLoad(tvc: StatefulTableView) -> UIView? {
        let initialErrorView = LoadingAndErrorView.loadFromNib()
        initialErrorView.backgroundColor = self.view.backgroundColor
        initialErrorView.showLoading()
        return initialErrorView
    }
    
    func statefulTableViewInitialErrorView(tvc: StatefulTableView, forInitialLoadError: NSError?) -> UIView? {
        if forInitialLoadError == nil {
            let title = "No Cart"
            let subTitle = "Please add items to create a cart\nTap to refresh"
            
            let emptyDataView = EmptyDataView.loadFromNib()
            emptyDataView.backgroundColor = self.view.backgroundColor
            emptyDataView.setTitle(title: title, desc: subTitle, iconImageName: "icon_loading", buttonTitle: "")
            
            emptyDataView.actionHandler = { (sender: UIButton) in
                tvc.triggerInitialLoad()
            }
            
            return emptyDataView
            
        } else {
            let initialErrorView = LoadingAndErrorView.loadFromNib()
            initialErrorView.showErrorView(canRetry: true)
            initialErrorView.backgroundColor = self.view.backgroundColor
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
        loadingView.backgroundColor = self.view.backgroundColor
        
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
extension MyCartViewController {
    @objc func foodCartUpdatedNotification(notification: Notification) {
        self.reset()
    }
    
    @objc func drinkCartUpdatedNotification(notification: Notification) {
        self.reset()
    }
    
    @objc func myCartUpdatedNotification(notification: Notification) {
        if (notification.object as? OrderItemCartUpdatedObject)?.controller != self {
            self.reset()
        }
    }
}
