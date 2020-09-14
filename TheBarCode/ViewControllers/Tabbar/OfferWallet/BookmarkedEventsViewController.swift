//
//  BookmarkedEventsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 28/10/2019.
//  Copyright © 2019 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import Alamofire
import ObjectMapper
import CoreStore

class BookmarkedEventsViewController: UIViewController {
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(eventBookmarkedNotification(notification:)), name: notificationNameEventBookmarked, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(bookmarkedEventRemoved(notification:)), name: notificationNameBookmarkedEventRemoved, object: nil)
        
        self.setUpStatefulTableView()
        self.statefulTableView.triggerInitialLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.statefulTableView.innerTable.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameEventBookmarked, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameBookmarkedEventRemoved, object: nil)
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
        self.statefulTableView.innerTable.estimatedRowHeight = 310.0
        self.statefulTableView.innerTable.tableFooterView = UIView()
        self.statefulTableView.innerTable.separatorStyle = .none
        
        self.statefulTableView.innerTable.register(cellType: EventCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
    }
    
    func setupForEmptyDataSetIfNeeded() {
        if !self.loadMore.isLoading {
            self.showHideEmptyDatasetForcefully = true
            self.statefulTableView.triggerInitialLoad()
        }
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension BookmarkedEventsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: EventCell.self)
        
        let event = self.events[indexPath.row]
        cell.setupCell(event: event, barName: event.bar.value?.title.value)
        
        cell.eventCellDelegate = self
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

//MARK: EventCellDelegate
extension BookmarkedEventsViewController: EventCellDelegate {
    func eventCell(cell: EventCell, bookmarkButtonTapped sender: UIButton) {
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("Indexpath not found")
            return
        }
        
        let event = self.events[indexPath.row]
        self.updateBookmarkStatus(event: event, isBookmarked: false)
    }
    
    func eventCell(cell: EventCell, shareButtonTapped sender: UIButton) {
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
}

//MARK: Webservices Methods
extension BookmarkedEventsViewController {
    
    func getBookmarkedEvents(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.loadMore = Pagination()
        }
        
        let params: [String : Any] = ["pagination" : true,
                                      "page": self.loadMore.next]
        
        self.loadMore.isLoading = true
        self.dataRequest  = APIHelper.shared.hitApi(params: params, apiPath: apiPathBookmarkedEvents, method: .get) { (response, serverError, error) in
            
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
            
            event.savingBookmarkStatus = false
            
            let index = self.events.firstIndex(of: event)
            
            guard error == nil else {
                self.statefulTableView.innerTable.reloadData()
                self.showAlertController(title: "", msg: error!.localizedDescription)
                debugPrint("Error while saving bookmark event status: \(error!.localizedDescription)")
                return
            }
            
            guard serverError == nil else {
                self.statefulTableView.innerTable.reloadData()
                debugPrint("Server error while saving bookmark event status: \(serverError!.errorMessages())")
                self.showAlertController(title: "", msg: serverError!.errorMessages())
                return
            }
            
            try! Utility.barCodeDataStack.perform(synchronous: { (transaction) -> Void in
                let edittedEvent = transaction.edit(event)
                edittedEvent?.isBookmarked.value = isBookmarked
            })
            
            if let index = index {
                self.events.remove(at: index)
                let indexPath = IndexPath(row: index, section: 0)
                self.statefulTableView.innerTable.deleteRows(at: [indexPath], with: .bottom)
            } else {
                self.statefulTableView.innerTable.reloadData()
            }
            
            self.setupForEmptyDataSetIfNeeded()
            
        }
        
    }
}


//MARK: StatefulTableDelegate
extension BookmarkedEventsViewController: StatefulTableDelegate {
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        if self.showHideEmptyDatasetForcefully {
            self.showHideEmptyDatasetForcefully = false
            handler(self.events.count == 0, nil)
        } else {
            self.getBookmarkedEvents(isRefreshing: false) {  [unowned self] (error) in
                debugPrint("bookmarked events count: \(self.events.count)")
                handler(self.events.count == 0, error)
            }
        }
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.loadMore.error = nil
        tvc.innerTable.reloadData()
        
        self.getBookmarkedEvents(isRefreshing: false) { [unowned self] (error) in
            handler(self.loadMore.canLoadMore(), error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getBookmarkedEvents(isRefreshing: true) { [unowned self] (error) in
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
            let title = "No Bookmarked Event Available"
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

//MARK: Notification Methods
extension BookmarkedEventsViewController {
    
    @objc func eventBookmarkedNotification(notification: Notification) {
        let event  = notification.object as! Event
        self.events.insert(event, at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.statefulTableView.innerTable.insertRows(at: [indexPath], with: .bottom)
        self.setupForEmptyDataSetIfNeeded()
    }
    
    @objc func bookmarkedEventRemoved(notification: Notification) {
        let event = notification.object as! Event
        if let index = self.events.firstIndex(of: event) {
            self.events.remove(at: index)
            let indexPath = IndexPath(row: index, section: 0)
            self.statefulTableView.innerTable.deleteRows(at: [indexPath], with: .top)
        } else {
            self.statefulTableView.innerTable.reloadData()
        }
        
        self.setupForEmptyDataSetIfNeeded()
    }
}

