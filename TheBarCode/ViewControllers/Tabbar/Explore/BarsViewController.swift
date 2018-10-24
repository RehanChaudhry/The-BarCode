//
//  BarsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 17/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import Reusable
import CoreStore
import Alamofire
import ObjectMapper
import HTTPStatusCodes

protocol BarsViewControllerDelegate: class {
    func barsController(controller: BarsViewController, didSelectBar bar: Bar)
}

class BarsViewController: ExploreBaseViewController {
    
    weak var delegate: BarsViewControllerDelegate!
    
    let transaction = Utility.inMemoryStack.beginUnsafe()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.searchBar.delegate = self
        self.snackBar.loadingSpinner()

        checkReloadStatus()
        
        self.statefulTableView.triggerInitialLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: My Methods
    override func setUpStatefulTableView() {
        super.setUpStatefulTableView()
        
        self.statefulTableView.innerTable.register(cellType: BarTableViewCell.self)        
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
    }

    func checkReloadStatus() {

        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathReloadStatus, method: .get) { (response, serverError, error) in
            
            guard error == nil else {
                debugPrint("Error while getting reload status \(String(describing: error?.localizedDescription))")
                self.updateSnakeBar()
                return
            }
            
            guard serverError == nil else {
                if serverError!.statusCode == HTTPStatusCode.notFound.rawValue {
                    //Show alert when tap on reload
                    //All your deals are already unlocked no need to reload                    
                    ReedeemInfoManager.shared.canReload = false
                    self.updateSnakeBar()
                    
                } else {
                    debugPrint("Error while getting reload status \(String(describing: serverError?.errorMessages()))")
                    self.updateSnakeBar()
                }
                
                return
            }
            
            let responseDict = ((response as? [String : Any])?["response"] as? [String : Any])
            if let responseReloadStatusDict = (responseDict?["data"] as? [String : Any]) {
                
                // let redeemInfo = Mapper<RedeemInfo>().map(JSON: responseReloadStatusDict)!
                
                // debugPrint("current servertimer \(redeemInfo .currentServerDatetime!)")
                // debugPrint("redeem time \(redeemInfo .redeemDatetime!)!")
                ReedeemInfoManager.shared.canReload = true
                ReedeemInfoManager.shared.saveRedeemInfo(redeemDic: responseReloadStatusDict)
                self.updateSnakeBar()
                
            } else {
                self.updateSnakeBar()
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("Error while getting reload status \(genericError.localizedDescription)")
            }
        }
    }
}

//MARK: UITableViewDataSource, UITableViewDelegate

extension BarsViewController: UITableViewDataSource, UITableViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return self.filteredBars.count
        }
        return self.bars.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.statefulTableView.innerTable.dequeueReusableCell(for: indexPath, cellType: BarTableViewCell.self)
        cell.delegate = self
       
        let bar = self.isSearching
                    ? self.filteredBars[indexPath.row]
                    : self.bars[indexPath.row]
        
        cell.setUpCell(bar: bar)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.statefulTableView.innerTable.deselectRow(at: indexPath, animated: false)
       
        let bar = self.isSearching ? self.filteredBars[indexPath.row]
                    : self.bars[indexPath.row]

        self.delegate.barsController(controller: self, didSelectBar: bar)
    }
}

//MARK: UISearchBarDelegate

extension BarsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        if searchBar.text == "" {
            self.searchText = searchBar.text!
            self.isSearching = false
            self.statefulTableView.innerTable.reloadData()
        } else {
            self.isSearching = true
            self.filteredBars.removeAll()
            self.statefulTableView.innerTable.reloadData()
            self.searchText = searchBar.text!
            self.statefulTableView.triggerInitialLoad()
        }
    }
 
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = searchBar.text!
        self.isSearching = false
        self.statefulTableView.innerTable.reloadData()
    }
}

//MARK: Webservices Methods
extension BarsViewController {
    func getBars(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {

        if isRefreshing {
            self.loadMore = Pagination()
        }
        
        var params:[String : Any] =  ["type": ExploreType.bars.rawValue]

        
        if self.isSearching {
            params["pagination"] = false
            params["keyword"] = self.searchText
            
        } else {
            params["pagination"] = true
            params["page"] = self.loadMore.next
        }
        
        self.loadMore.isLoading = true
        
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiEstablishment, method: .get) { (response, serverError, error) in
            
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
                
                if self.isSearching {
                    self.filteredBars.removeAll()
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
                

                if self.isSearching {
                    self.filteredBars = resultBars
                    self.statefulTableView.canLoadMore = false
                    self.statefulTableView.innerTable.reloadData()
                    self.statefulTableView.reloadData()
                    completion(nil)
                } else {
                    self.bars = resultBars
                    self.loadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                    self.statefulTableView.canLoadMore = self.loadMore.canLoadMore()
                    self.statefulTableView.innerTable.reloadData()
                    completion(nil)
                }
                
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
        }
    }
    
    func markFavourite(bar: Bar, cell: BarTableViewCell) {
        
        debugPrint("isFav == \(bar.isUserFavourite.value)")
        let params:[String : Any] = ["establishment_id": bar.id.value, "is_favorite" : !(bar.isUserFavourite.value)]
        
        let editedObject = transaction.edit(bar)
        editedObject!.isUserFavourite.value = !(editedObject!.isUserFavourite.value)
        
        
        let color =  bar.isUserFavourite.value == true ? UIColor.appBlueColor() : UIColor.appLightGrayColor()
        
        cell.favouriteButton.tintColor = color
        
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
                //                try! Utility.inMemoryStack.perform(synchronous: { (transaction) -> Void in
                //                    let editedObject = transaction.edit(self.bar)
                //                    editedObject!.isUserFavourite.value = !editedObject!.isUserFavourite.value
                //                })
                //
                //                self.bar.isUserFavourite.value = !(self.bar.isUserFavourite.value)
                
                try! self.transaction.commitAndWait()
                
                
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("genericError == \(String(describing: genericError.localizedDescription))")
            }
        }
    }
}

extension BarsViewController: StatefulTableDelegate {
    
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        
        let refreshing  = self.isSearching ? false : true
        self.getBars(isRefreshing: refreshing) {  [unowned self] (error) in
            handler(self.bars.count == 0, error)
        }
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.loadMore.error = nil
        tvc.innerTable.reloadData()
        
        self.getBars(isRefreshing: false) { [unowned self] (error) in
            handler(self.loadMore.canLoadMore(), error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getBars(isRefreshing: true) { [unowned self] (error) in
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
            let title = isSearching ? "No Search Result Found" : "No Bars Available"
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

extension BarsViewController: BarTableViewCellDelegare {
    func barTableViewCell(cell: BarTableViewCell, favouriteButton sender: UIButton) {
        let indexPath = self.statefulTableView.innerTable.indexPath(for: cell)
        let bar = self.bars[indexPath!.row]
        markFavourite(bar: bar, cell: cell)
    }
}


