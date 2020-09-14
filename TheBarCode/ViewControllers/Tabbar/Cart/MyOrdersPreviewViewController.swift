//
//  MyOrdersController.swift
//  TheBarCode
//
//  Created by Macbook on 16/07/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import CoreStore
import ObjectMapper
import Alamofire
import FirebaseAnalytics
import Reusable

class MyOrdersPreviewViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var ongoingOrders: [Order] = []
    var completedOrders: [Order] = []
  
    var limit: Int = 5
    
    enum MyOrderState: String {
        case none = "none",
        loading = "loading",
        error = "error",
        empty = "empty",
        loaded = "loaded"
    }
    
    var ongoingOrderState: MyOrderState = .none
    var completedOrderState: MyOrderState = .none
    
    var ongoingOrderRequest: DataRequest?
    var completedOrderRequest: DataRequest?
    
    var hasMoreOngoingOrders: Bool = false
    var hasMoreCompletedOrders: Bool = false
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupTableView()
        
        self.getCompletedOrders()
        self.getOnGoingOrders()
        
        NotificationCenter.default.addObserver(self, selector: #selector(orderDetailsDidRefreshed(notif:)), name: notificationNameOrderDidRefresh, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orderStatusUpdatedNotification(notification:)), name: notificationNameOrderStatusUpdated, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameOrderDidRefresh, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameOrderStatusUpdated, object: nil)
    }
    
    //MARK: My Methods
   func setupTableView() {
        
        self.tableView.register(cellType: MyOrderLoadingStateCell.self)
        self.tableView.register(cellType: OrderTableViewCell.self)
        self.tableView.register(headerFooterViewType: SectionHeaderView.self)
        self.tableView.register(headerFooterViewType: MyOrderFooterView.self)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
    

        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 8))
        tableHeaderView.backgroundColor = UIColor.clear
        self.tableView.tableHeaderView = tableHeaderView
    
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.addTarget(self, action: #selector(didTriggerPullToRefresh(sender:)), for: .valueChanged)
        self.tableView.refreshControl = self.refreshControl

    }
    
    func moveToOrderDetailsVC(order: Order) {
        
        let orderDetailsNavigation = (self.storyboard?.instantiateViewController(withIdentifier: "OrderDetailsNavigation") as! UINavigationController)
        orderDetailsNavigation.modalPresentationStyle = .fullScreen
               
        let orderDetailsViewController = orderDetailsNavigation.viewControllers.first as! OrderDetailsViewController
        orderDetailsViewController.order = order
        
        self.present(orderDetailsNavigation, animated: true, completion: nil)
    }

    func moveToMyOrdersFor(status: OrderStatus, orders: [Order]) {
        let myordersNavigation = (self.storyboard!.instantiateViewController(withIdentifier: "MyOrdersNavigation") as! UINavigationController)
        myordersNavigation.modalPresentationStyle = .fullScreen
        
        let myordersController = (myordersNavigation.viewControllers.first! as! MyOrdersViewController)
        myordersController.limit = self.limit
        myordersController.loadMore.next = 2
        myordersController.orders = orders
        myordersController.status = status.rawValue
        self.present(myordersNavigation, animated: true, completion: nil)
    }
    
    @objc func didTriggerPullToRefresh(sender: UIRefreshControl) {
        self.getOnGoingOrders()
        self.getCompletedOrders()
    }
    
    func finishPullToRefresh() {
        if self.ongoingOrderState != .loading && self.completedOrderState != .loading {
            self.refreshControl.endRefreshing()
        }
    }
}

//MARK: Webservices Methods
extension MyOrdersPreviewViewController {
    func getOnGoingOrders() {
        
        self.ongoingOrderRequest?.cancel()
        self.ongoingOrderState = .loading
        
        self.tableView.reloadData()
        
        let params: [String : Any] = ["status" : OrderStatus.ongoing.rawValue,
                                      "pagination" : true,
                                      "limit" : self.limit]
        self.ongoingOrderRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathOrders, method: .get, completion: { (response, serverError, error) in

            defer {
                self.finishPullToRefresh()
                self.tableView.reloadData()
            }
            
            guard error == nil else {
                self.ongoingOrderState = .error
                return
            }
            
            guard serverError == nil else {
                self.ongoingOrderState = .error
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let data = responseDict?["data"] as? [[String : Any]] {
                
                let context = OrderMappingContext(type: .order)
                let orders = Mapper<Order>(context: context).mapArray(JSONArray: data)
                
                if orders.count == 0 {
                    self.ongoingOrderState = .empty
                    self.hasMoreOngoingOrders = false
                } else {
                    self.ongoingOrders.removeAll()
                    self.ongoingOrders.append(contentsOf: orders)
                    
                    self.ongoingOrderState = .loaded
                    self.hasMoreOngoingOrders = orders.count >= self.limit
                }
            } else {
                self.ongoingOrderState = .error
                self.hasMoreOngoingOrders = false
            }
            
        })
    }
    
    func getCompletedOrders() {
        
        self.completedOrderRequest?.cancel()
        self.completedOrderState = .loading
        
        self.tableView.reloadData()
        
        let params: [String : Any] = ["status" : OrderStatus.completed.rawValue,
                                      "pagination" : true,
                                      "limit" : self.limit]
        self.completedOrderRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathOrders, method: .get, completion: { (response, serverError, error) in
            
            defer {
                self.finishPullToRefresh()
                self.tableView.reloadData()
            }
            
            guard error == nil else {
                self.completedOrderState = .error
                return
            }
            
            guard serverError == nil else {
                self.completedOrderState = .error
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let data = responseDict?["data"] as? [[String : Any]] {
                
                let context = OrderMappingContext(type: .order)
                let orders = Mapper<Order>(context: context).mapArray(JSONArray: data)
                
                if orders.count == 0 {
                    self.completedOrderState = .empty
                    self.hasMoreCompletedOrders = false
                } else {
                    self.completedOrders.removeAll()
                    self.completedOrders.append(contentsOf: orders)
                    
                    self.completedOrderState = .loaded
                    
                    self.hasMoreCompletedOrders = orders.count >= self.limit
                }
                
                
            } else {
                self.completedOrderState = .error
                self.hasMoreCompletedOrders = false
            }
            
        })
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension MyOrdersPreviewViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            switch self.ongoingOrderState {
            case .loaded:
                return self.hasMoreOngoingOrders ? 44.0 : 0.0
            default:
                return 0.0
            }
        } else if section == 1 {
            switch self.completedOrderState {
            case .loaded:
                return self.hasMoreCompletedOrders ? 44.0 : 0.0
            default:
                return 0.0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = self.tableView.dequeueReusableHeaderFooterView(MyOrderFooterView.self)
        footerView?.section = section
        footerView?.delegate = self
        if section == 0 {
            footerView?.setUpFooterView(title: "View more ongoing orders")
        } else if section == 1 {
            footerView?.setUpFooterView(title: "View more completed orders")
        } else {
            footerView?.setUpFooterView(title: "")
        }
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            switch self.ongoingOrderState {
            case .loaded:
                return self.ongoingOrders.count
            case .empty, .loading, .error:
                return 1
            default:
                return 0
            }
        } else if section == 1 {
            switch self.completedOrderState {
            case .loaded:
                return self.completedOrders.count
            case .empty, .loading, .error:
                return 1
            default:
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(SectionHeaderView.self)
        if section == 0 {
            headerView?.setupHeader(title: "Ongoing Orders")
        } else if section == 1 {
            headerView?.setupHeader(title: "Completed Orders")
        } else {
            headerView?.setupHeader(title: "")
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            switch self.ongoingOrderState {
            case .empty:
                let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: MyOrderLoadingStateCell.self)
                cell.show(title: "No Orders", subtitle: "Tap to refresh")
                cell.delegate = self
                return cell
            case .error:
                let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: MyOrderLoadingStateCell.self)
                cell.show(title: "No or weak internet connection", subtitle: "Tap to refresh")
                cell.delegate = self
                return cell
            case .loading:
                let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: MyOrderLoadingStateCell.self)
                cell.showLoading()
                return cell
            case .loaded:
                let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: OrderTableViewCell.self)
                cell.setUpCell(order: self.ongoingOrders[indexPath.row])
                return cell
            default:
                return UITableViewCell()
            }
        } else if indexPath.section == 1 {
            switch self.completedOrderState {
            case .empty:
                let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: MyOrderLoadingStateCell.self)
                cell.show(title: "No Orders", subtitle: "Tap to refresh")
                cell.delegate = self
                return cell
            case .error:
                let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: MyOrderLoadingStateCell.self)
                cell.show(title: "No or weak internet connection", subtitle: "Tap to refresh")
                cell.delegate = self
                return cell
            case .loading:
                let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: MyOrderLoadingStateCell.self)
                cell.showLoading()
                return cell
            case .loaded:
                let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: OrderTableViewCell.self)
                cell.setUpCell(order: self.completedOrders[indexPath.row])
                return cell
            default:
                return UITableViewCell()
            }
        } else {
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let order = self.ongoingOrders[indexPath.row]
            self.moveToOrderDetailsVC(order: order)
        } else if indexPath.section == 1 {
            let order = self.completedOrders[indexPath.row]
            self.moveToOrderDetailsVC(order: order)
        }
    }
}

//MARK: MyOrderLoadingStateCellDelegate
extension MyOrdersPreviewViewController: MyOrderLoadingStateCellDelegate {
    func myOrderLoadingStateCell(cell: MyOrderLoadingStateCell, bgButtonTapped sender: UIButton) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            return
        }
        
        if indexPath.section == 0 {
            self.getOnGoingOrders()
        } else if indexPath.section == 1 {
            self.getCompletedOrders()
        }
    }
}

//MARK: MyOrderFooterViewDelegate
extension MyOrdersPreviewViewController: MyOrderFooterViewDelegate {
    func myOrderFooterView(footerView: MyOrderFooterView, viewMoreButtonTapped sender: UIButton) {
        if footerView.section == 0 {
            self.moveToMyOrdersFor(status: .ongoing, orders: self.ongoingOrders)
        } else if footerView.section == 1 {
            self.moveToMyOrdersFor(status: .completed, orders: self.completedOrders)
        }
    }
}

//MARK: Notification Methods
extension MyOrdersPreviewViewController {
    @objc func orderDetailsDidRefreshed(notif: Notification) {
        if let order = notif.object as? Order {
            
            var needsRefresh: Bool = false
            if let index = self.ongoingOrders.firstIndex(where: {$0.orderNo == order.orderNo}) {
                if order.status == .completed {
                    needsRefresh = true
                } else {
                    self.ongoingOrders[index] = order
                }

            } else if let index = self.completedOrders.firstIndex(where: {$0.orderNo == order.orderNo}) {
                if self.completedOrders[index].statusRaw == order.statusRaw {
                    self.completedOrders[index] = order
                } else {
                    needsRefresh = true
                }
            }
            
            if needsRefresh {
                self.getOnGoingOrders()
                self.getCompletedOrders()
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func orderStatusUpdatedNotification(notification: Notification) {
        self.getOnGoingOrders()
        self.getCompletedOrders()
    }
}
