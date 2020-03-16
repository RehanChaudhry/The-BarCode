//
//  SharedEventsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import Alamofire
import Reusable
import FirebaseAnalytics
import ObjectMapper
import CoreStore
import MGSwipeTableCell

class SharedEventsViewController: UIViewController {
    
    @IBOutlet var statefulTableView: StatefulTableView!
    
    var events: [Event] = []
    
    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    var loadingShareController: Bool = false
    var showHideEmptyDatasetForcefully: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        self.setUpStatefulTableView()
        self.resetEvents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(resetAllSharedEventsNotificationReceived(notif:)), name: notificationNameReloadAllSharedEvents, object: nil)
        
        Analytics.logEvent(viewSharedEventScreen, parameters: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.statefulTableView.innerTable.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameReloadAllSharedEvents, object: nil)
    }
    
    //MARK: My Methods
    
    func resetEvents() {
        self.dataRequest?.cancel()
        self.loadMore = Pagination()
        self.events.removeAll()
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
        self.statefulTableView.innerTable.estimatedRowHeight = 310.0
        self.statefulTableView.innerTable.tableFooterView = UIView()
        self.statefulTableView.innerTable.separatorStyle = .none
        
        self.statefulTableView.innerTable.register(cellType: SharedEventCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
    }
    
    func showDirection(bar: Bar) {
        let mapUrl = "https://www.google.com/maps/dir/?api=1&destination=\(bar.latitude.value)+\(bar.longitude.value)"
        UIApplication.shared.open(URL(string: mapUrl)!, options: [:]) { (success) in
            
        }
    }
    
    func setupForEmptyDataSetIfNeeded() {
        if !self.loadMore.isLoading {
            self.showHideEmptyDatasetForcefully = true
            self.statefulTableView.triggerInitialLoad()
        }
    }
    
    //MARK: My IBActions
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

//MARK: UITableViewDataSource, UITableViewDelegate
extension SharedEventsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: SharedEventCell.self)
        
        let event = self.events[indexPath.row]
        cell.setUpCell(event: event)
        cell.sharingDelegate = self
        
        let deleteButton = MGSwipeButton(title: "", icon: UIImage(named: "icon_trash"), backgroundColor: nil) { (cell) -> Bool in
            
            guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
                debugPrint("Indexpath not found")
                return true
            }
            
            let reachabilityManager = NetworkReachabilityManager()
            guard reachabilityManager?.isReachable == true else {
                self.showAlertController(title: "", msg: "No or weak internet connection")
                return true
            }
            
            let event = self.events[indexPath.row]
            self.events.remove(at: indexPath.row)
            self.statefulTableView.innerTable.deleteRows(at: [indexPath], with: .top)
            
            self.setupForEmptyDataSetIfNeeded()
            
            self.deleteSharedEvent(event: event)
            
            return true
        }
        
        cell.rightButtons = [deleteButton]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let eventCell = cell as? EventCell
        eventCell?.startTimer(event: self.events[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let eventCell = cell as? EventCell
        eventCell?.stopTimer()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        let event = self.events[indexPath.row]
        
        let eventDetailController = (self.storyboard!.instantiateViewController(withIdentifier: "EventDetailViewController") as! EventDetailViewController)
        eventDetailController.event = event
        self.navigationController?.pushViewController(eventDetailController, animated: true)
    }
}

//MARK: Webservices Methods
extension SharedEventsViewController {
    
    func getSharedEvents(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.loadMore = Pagination()
        }
        
        let params:[String : Any] = ["pagination" : true,
                                     "page": self.loadMore.next]
        
        self.loadMore.isLoading = true
        self.dataRequest  = APIHelper.shared.hitApi(params: params, apiPath: apiPathSharedEvents, method: .get) { (response, serverError, error) in
            
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
                    self.events.removeAll()
                }
                
                var importedObjects: [Event] = []
                try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                    importedObjects.append(contentsOf:  try! transaction.importUniqueObjects(Into<Event>(), sourceArray: responseArray))
                })
                
                for object in importedObjects {
                    let fetchedObject = Utility.barCodeDataStack.fetchExisting(object)
                    self.events.append(fetchedObject!)
                }
                
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
    
    func updateBookmarkStatus(event: Event, isBookmarked: Bool) {
        
        guard !event.savingBookmarkStatus else {
            debugPrint("Already saving bookmark status")
            return
        }
        
        event.savingBookmarkStatus = true
        self.statefulTableView.innerTable.reloadData()
        
        let eventId: String = event.id.value
        
        let params: [String : Any] = ["event_id" : eventId,
                                      "is_favorite" : isBookmarked]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathAddRemoveBookmarkedEvents, method: .put) { (response, serverError, error) in
            
            defer {
                self.statefulTableView.innerTable.reloadData()
            }
            
            event.savingBookmarkStatus = false

            guard error == nil else {
                self.showAlertController(title: "", msg: error!.localizedDescription)
                debugPrint("Error while saving bookmark event status: \(error!.localizedDescription)")
                return
            }
            
            guard serverError == nil else {
                debugPrint("Server error while saving bookmark event status: \(serverError!.errorMessages())")
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let edittedEvent = transaction.edit(event)
                edittedEvent?.isBookmarked.value = isBookmarked
            })
            
            if isBookmarked {
                NotificationCenter.default.post(name: notificationNameEventBookmarked, object: event)
            } else {
                NotificationCenter.default.post(name: notificationNameBookmarkedEventRemoved, object: event)
            }
        }
        
    }
    
    func deleteSharedEvent(event: Event) {
        
        guard let eventSharedId = event.sharedId.value else {
            debugPrint("Shared id not available")
            return
        }
        
        let deleteSharedEvent = apiPathSharedEvents + "/" + eventSharedId

        let _ = APIHelper.shared.hitApi(params: [:], apiPath: deleteSharedEvent, method: .delete) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("Error while deleting shared event: \(error!.localizedDescription)")
                return
            }
            
            guard serverError == nil else {
                debugPrint("Server error while deleting shared event: \(serverError!.errorMessages())")
                return
            }
            
            debugPrint("shared event has been deleted: \(eventSharedId)")
        }
    }
    
}


//MARK: StatefulTableDelegate
extension SharedEventsViewController: StatefulTableDelegate {
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        if self.showHideEmptyDatasetForcefully {
            self.showHideEmptyDatasetForcefully = false
            handler(self.events.count == 0, nil)
        } else {
            self.getSharedEvents(isRefreshing: false) {  [unowned self] (error) in
                handler(self.events.count == 0, error)
            }
        }
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.loadMore.error = nil
        tvc.innerTable.reloadData()
        
        self.getSharedEvents(isRefreshing: false) { [unowned self] (error) in
            handler(self.loadMore.canLoadMore(), error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getSharedEvents(isRefreshing: true) { [unowned self] (error) in
            handler(self.events.count == 0, error)
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
            let title = "No Shared Event Available"
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

//MARK: EventCellDelegate
extension SharedEventsViewController: SharedEventCellDelegate {
    
    func sharedEventCell(cell: SharedEventCell, bookmarkButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let event = self.events[indexPath.row]
        self.updateBookmarkStatus(event: event, isBookmarked: !event.isBookmarked.value)
    }
    
    func sharedEventCell(cell: SharedEventCell, shareButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        guard !self.loadingShareController else {
            debugPrint("Loading sharing controller is already in progress")
            return
        }
        
        self.loadingShareController = true
        
        let event = self.events[indexPath.row]
        event.showSharingLoader = true
        self.statefulTableView.innerTable.reloadData()
        
        Utility.shared.generateAndShareDynamicLink(event: event, controller: self, presentationCompletion: {
            event.showSharingLoader = false
            self.statefulTableView.innerTable.reloadData()
            self.loadingShareController = false
        }) {
            
        }
    }
    
    func sharedEventCell(cell: SharedEventCell, barButtonTapped sender: UIButton) {
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let event = self.events[indexPath.row]
        
        let barId = event.establishmentId.value
        
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
        barDetailNav.modalPresentationStyle = .fullScreen
        
        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
        barDetailController.barId = barId
        self.present(barDetailNav, animated: true, completion: nil)
        
    }
}

//MARK: Notification Methods
extension SharedEventsViewController {
    @objc func resetAllSharedEventsNotificationReceived(notif: Notification) {
        self.resetEvents()
    }
}

