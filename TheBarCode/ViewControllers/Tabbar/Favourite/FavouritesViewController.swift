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

class FavouritesViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    var bars: [Bar] = []
    
    var dealsRequest: DataRequest?
    var dealsLoadMore = Pagination()
    
    var shouldShowEmptyDataView = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 21))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.appBoldFontOf(size: 16.0)
        titleLabel.textColor = UIColor.white
        titleLabel.text = "Favourites"
        self.navigationItem.titleView = titleLabel
        
        self.setUpStatefulTableView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.bars.removeAll()
        self.statefulTableView.innerTable.reloadData()
        self.statefulTableView.triggerInitialLoad()
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
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            let urlString = String(format: "comgooglemaps://?daddr=%f,%f&directionsmode=driving",bar.latitude.value,bar.longitude.value)
            let url = URL(string: urlString)
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            let url = URL(string: "https://itunes.apple.com/us/app/google-maps-transit-food/id585027354?mt=8")
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
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
        cell.setUpCell(bar: self.bars[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
        
        self.moveToBarDetail(bar: self.bars[indexPath.row])
        
//        let exploreDetailNav = (self.storyboard?.instantiateViewController(withIdentifier: "ExploreDetailNavigation") as! UINavigationController)
//        self.present(exploreDetailNav, animated: true, completion: nil)
    }
}


//MARK: Webservices Methods
extension FavouritesViewController {
    func getFavourites(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.dealsLoadMore = Pagination()
        }
        
        let params:[String : Any] = ["pagination" : true,"page": self.dealsLoadMore.next]
        self.dealsLoadMore.isLoading = true

        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiFavorite, method: .get) { (response, serverError, error) in
            
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
                
                self.dealsLoadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                self.statefulTableView.canPullToRefresh = true
                self.statefulTableView.canLoadMore = self.dealsLoadMore.canLoadMore()
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
            let editedObject = transaction.edit(bar)
            editedObject!.isUserFavourite.value = !editedObject!.isUserFavourite.value
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
        
        if !self.dealsLoadMore.isLoading && self.bars.count == 0 {
            self.shouldShowEmptyDataView = true
            self.statefulTableView.triggerInitialLoad()
        }
    }
}

extension FavouritesViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        if self.shouldShowEmptyDataView {
            self.shouldShowEmptyDataView = false
            handler(self.bars.count == 0, nil)
        } else {
            self.getFavourites(isRefreshing: false) {  [unowned self] (error) in
                handler(self.bars.count == 0, error)
            }
        }
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.dealsLoadMore.error = nil
        tvc.innerTable.reloadData()
        
        self.getFavourites(isRefreshing: false) { [unowned self] (error) in
            handler(self.dealsLoadMore.canLoadMore(), error, error != nil)
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
            let title = "No Favorite Bar"
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
