//
//  FavouritesViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import CoreStore
import ObjectMapper
import Alamofire
import FirebaseAnalytics
import CoreLocation

class FavouritesViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    var bars: [Bar] = []
    
    var dataRequest: DataRequest?
    var loadMore = Pagination()
    
    var showHideEmptyDatasetForcefully: Bool = false
    
    var shouldShowFirstItemPadding = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(establishmentMarkAsFavouriteNotification(notification:)), name: notificationNameBarFavouriteAdded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(establishmentRemovedAsFavouriteNotification(notification:)), name: notificationNameBarFavouriteRemoved, object: nil)
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 21))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.appBoldFontOf(size: 16.0)
        titleLabel.textColor = UIColor.white
        titleLabel.text = "Favourites"
        self.navigationItem.titleView = titleLabel
        
        self.setUpStatefulTableView()
        self.statefulTableView.triggerInitialLoad()
        
        Analytics.logEvent(viewFavouriteScreen, parameters: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: notificationNameBarFavouriteAdded, object: nil)
        NotificationCenter.default.removeObserver(self, name: notificationNameBarFavouriteRemoved, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.statefulTableView.innerTable.reloadData()
    }
    
    func setUpStatefulTableView() {
        
        self.statefulTableView.innerTable.register(cellType: BarTableViewCell.self)
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        
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
        self.statefulTableView.statefulDelegate = self

    }
    
    func moveToBarDetail(bar: Bar) {
        let barDetailNav = (self.storyboard!.instantiateViewController(withIdentifier: "BarDetailNavigation") as! UINavigationController)
        let barDetailController = (barDetailNav.viewControllers.first as! BarDetailViewController)
        barDetailController.selectedBar = bar
        barDetailController.delegate = self
        self.present(barDetailNav, animated: true, completion: nil)
    }
    
    func showDirection(bar: Bar) {
        let user = Utility.shared.getCurrentUser()!

        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let source = CLLocationCoordinate2D(latitude: user.latitude.value, longitude: user.longitude.value)
            
            let urlString = String(format: "comgooglemaps://?saddr=%f,%f&daddr=%f,%f&directionsmode=driving",source.latitude,source.longitude,bar.latitude.value,bar.longitude.value)
            let url = URL(string: urlString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            let url = URL(string: "https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        }
    }
    
    func setupForEmptyDataSetIfNeeded() {
        if !self.loadMore.isLoading {
            self.showHideEmptyDatasetForcefully = true
            self.statefulTableView.triggerInitialLoad()
        }
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension FavouritesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.bars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: BarTableViewCell.self)
        cell.delegate = self
        cell.exploreBaseDelegate = self
        
        cell.setUpCell(bar: self.bars[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let aCell = cell as? BarTableViewCell {
            aCell.scrollToCurrentImage()
            
            let bar = self.bars[indexPath.row]
            let imageCount = bar.images.value.count
            
            aCell.pagerView.automaticSlidingInterval = imageCount > 1 ? 2.0 : 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let aCell = cell as? BarTableViewCell {
            aCell.pagerView.automaticSlidingInterval = 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        self.moveToBarDetail(bar: self.bars[indexPath.row])
    }
}

//MARK: ExploreBaseTableViewCellDelegate
extension FavouritesViewController: ExploreBaseTableViewCellDelegate {
    func exploreBaseTableViewCell(cell: ExploreBaseTableViewCell, didSelectItem itemIndexPath: IndexPath) {
        guard let tableCellIndexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let bar = self.bars[tableCellIndexPath.row]
        self.moveToBarDetail(bar: bar)
    }
}


//MARK: Webservices Methods
extension FavouritesViewController {
    func getFavourites(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.loadMore = Pagination()
        }
        
        let params:[String : Any] = ["pagination" : true,"page": self.loadMore.next]
        self.loadMore.isLoading = true

        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiFavorite, method: .get) { (response, serverError, error) in
            
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
                
                var importedObjects: [Bar] = []
                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                    let objects = try! transaction.importUniqueObjects(Into<Bar>(), sourceArray: responseArray)
                    importedObjects.append(contentsOf: objects)
                })
                
                var resultBars: [Bar] = []
                for object in importedObjects {
                    let fetchedObject = Utility.inMemoryStack.fetchExisting(object)
                    //self.bars.append(fetchedObject!)
                    resultBars.append(fetchedObject!)
                }
                
                self.bars.append(contentsOf: resultBars)
                
                self.loadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                self.statefulTableView.canPullToRefresh = true
                self.statefulTableView.canLoadMore = self.loadMore.canLoadMore()
                self.statefulTableView.innerTable.reloadData()
                completion(nil)
                
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
    
    
    func markFavourite(bar: Bar, cell: BarTableViewCell) {
        
        debugPrint("isFav == \(bar.isUserFavourite.value)")
        let params:[String : Any] = ["establishment_id": bar.id.value,
                                     "is_favorite" : !(bar.isUserFavourite.value)]
        
        try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
            if let bars = transaction.fetchAll(From<Bar>(), Where<Bar>("%K == %@", String(keyPath: \Bar.id), bar.id.value)) {
                for bar in bars {
                    bar.isUserFavourite.value = !bar.isUserFavourite.value
                }
            }
        })
        
        cell.setUpCell(bar: bar)
        
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiUpdateFavorite, method: .put) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("error == \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard serverError == nil else {
                debugPrint("servererror == \(String(describing: serverError?.errorMessages()))")
                return
            }
            
            let response = response as! [String : Any]
            let responseDict = response["response"] as! [String : Any]
            
            if let responseID = (responseDict["data"] as? Int) {
                debugPrint("responseID == \(responseID)")
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("genericError == \(String(describing: genericError.localizedDescription))")
            }
        }
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            debugPrint("indexPath not found")
            return
        }
        
        self.bars.remove(at: indexPath.row)
        self.statefulTableView.innerTable.deleteRows(at: [indexPath], with: .fade)
        
        self.setupForEmptyDataSetIfNeeded()
    }
}

//MARK: StatefulTableDelegate
extension FavouritesViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        
        if self.showHideEmptyDatasetForcefully {
            self.showHideEmptyDatasetForcefully = false
            handler(self.bars.count == 0, nil)
        } else {
            self.getFavourites(isRefreshing: false) {  [unowned self] (error) in
                handler(self.bars.count == 0, error)
            }
        }
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.loadMore.error = nil
        tvc.innerTable.reloadData()
        
        self.getFavourites(isRefreshing: false) { [unowned self] (error) in
            handler(self.loadMore.canLoadMore(), error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getFavourites(isRefreshing: true) { [unowned self] (error) in
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
            let title = "No Favourite Bar Available"
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

//MARK: BarTableViewCellDelegare
extension FavouritesViewController: BarTableViewCellDelegare {
    func barTableViewCell(cell: BarTableViewCell, favouriteButton sender: UIButton) {
        let indexPath = self.statefulTableView.innerTable.indexPath(for: cell)
        let bar = self.bars[indexPath!.row]
        markFavourite(bar: bar, cell: cell)
    }
    
    func barTableViewCell(cell: BarTableViewCell, distanceButtonTapped sender: UIButton) {
        let indexPath = self.statefulTableView.innerTable.indexPath(for: cell)
        let bar = self.bars[indexPath!.row]
        self.showDirection(bar: bar)
    }
}

//MARK: BarDetailViewControllerDelegate
extension FavouritesViewController: BarDetailViewControllerDelegate {
    func barDetailViewController(controller: BarDetailViewController, cancelButtonTapped sender: UIBarButtonItem) {
    }
}

//MARK: Notification Methods
extension FavouritesViewController {
    @objc func establishmentMarkAsFavouriteNotification(notification: Notification) {
        
        let bar = notification.object as! Bar
        self.bars.insert(bar, at: 0)
        
        let indexPath = IndexPath(row: 0, section: 0)
        self.statefulTableView.innerTable.insertRows(at: [indexPath], with: .bottom)
        self.setupForEmptyDataSetIfNeeded()
    }
    
    @objc func establishmentRemovedAsFavouriteNotification(notification: Notification) {
        
        let bar = notification.object as! Bar
        
        let index = self.bars.firstIndex { (obj) -> Bool in
            return obj.id.value == bar.id.value
        }

        if let index = index {
            self.bars.remove(at: index)
            
            let indexPath = IndexPath(row: index, section: 0)
            self.statefulTableView.innerTable.deleteRows(at: [indexPath], with: .top)
        } else {
            self.statefulTableView.innerTable.reloadData()
        }
        
        self.setupForEmptyDataSetIfNeeded()
    }
}
