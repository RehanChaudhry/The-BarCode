//
//  NotificationsController.swift
//  TheBarCode
//
//  Created by Macbook on 06/05/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import CoreStore
import Alamofire
import ObjectMapper
import PureLayout
import FirebaseAnalytics

class NotificationsController: UIViewController {
  
    @IBOutlet var statefulTableView: StatefulTableView!
  
    var notifications: [NotificationItem] = []

    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setUpStatefulTableView()
        self.statefulTableView.triggerInitialLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshNotification(notification:)), name: notificationNameRefreshNotifications, object: nil)

    }
    
    deinit {
         NotificationCenter.default.removeObserver(self, name: notificationNameRefreshNotifications, object: nil)
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
           self.statefulTableView.innerTable.separatorStyle = .singleLine
           
           self.statefulTableView.innerTable.register(cellType: NotificationTableViewCell.self)
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

    
    //MARK: IBActions
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}


//MARK: UITableViewDataSource, UITableViewDelegate

extension NotificationsController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: NotificationTableViewCell.self)
        cell.setUpCell(notification: self.notifications[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Analytics.logEvent(notificationClickFromNotifications, parameters: nil)
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        let notification = self.notifications[indexPath.row]
        
        if notification.notificationType == NotificationType.event {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.eventBarId = notification.establishmentId
            NotificationCenter.default.post(name: notificationNameEvent, object: nil)
                        
        } else if notification.notificationType == NotificationType.exclusive {
    
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.exclusiveBarId = notification.establishmentId
            NotificationCenter.default.post(name: notificationNameExclusive, object: nil)
                            
        } else if notification.notificationType == NotificationType.chalkboard {

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.chalkboardBarId = notification.establishmentId
            NotificationCenter.default.post(name: notificationNameChalkboard, object: nil)
                            
        } else if notification.notificationType == NotificationType.fiveADay {
           
            self.dismiss(animated: true) {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.refreshFiveADay = true
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameFiveADayRefresh), object: nil)
            }
            
        } else if notification.notificationType == NotificationType.shareOffer {
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: Notification.Name(rawValue: notificationNameSharedOfferRedeemed), object: nil)
            }
                            
        } else if notification.notificationType == NotificationType.voucher {

            self.dismiss(animated: true) {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.voucherTitle = notification.offerTitle
                NotificationCenter.default.post(name: notificationNameVoucher, object: nil)
            }
                        
        } else {
                            
        }
        
        
    }
}



extension NotificationsController: StatefulTableDelegate {
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getNotifications(isRefreshing: true) { [unowned self] (error) in
            debugPrint("notifications== \(self.notifications.count)")
            handler(self.notifications.count == 0, error)
        }
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.loadMore.error = nil
        tvc.innerTable.reloadData()
        self.getNotifications(isRefreshing: false) { [unowned self] (error) in
            handler(self.loadMore.canLoadMore(), error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getNotifications(isRefreshing: true) { [unowned self] (error) in
            handler(self.notifications.count == 0, error)
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
            let title = "No Notification Available"
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

extension NotificationsController {
    func getNotifications(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.loadMore = Pagination()
        }
        
        let params: [String : Any] = ["pagination" : true,
                                      "page": self.loadMore.next,
                                      "limit" : 10]
        
        self.loadMore.isLoading = true
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathUserNotification, method: .get) { (response, serverError, error) in
            
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
                    self.notifications.removeAll()
                }
                
                var mappedObjects: [NotificationItem] = []
                mappedObjects = Mapper<NotificationItem>().mapArray(JSONArray: responseArray)
                self.notifications.append(contentsOf: mappedObjects)
                
                self.statefulTableView.canPullToRefresh = self.notifications.count > 0

                self.loadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                self.statefulTableView.canLoadMore = self.loadMore.canLoadMore()
                self.statefulTableView.innerTable.reloadData()
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
}

//MARK: Notification Methods
extension NotificationsController {
    @objc func refreshNotification(notification: Notification) {
        self.statefulTableView.triggerInitialLoad()
    }
}
