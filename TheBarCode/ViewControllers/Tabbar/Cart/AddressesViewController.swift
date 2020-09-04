//
//  AddressesViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 06/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView
import Alamofire
import ObjectMapper

protocol AddressesViewControllerDelegate: class {
    func addressesViewController(controller: AddressesViewController, didSelectAddress address: Address)
}

class AddressesViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    var addresses: [Address] = []
    
    var isSelectingAddress: Bool = false
    var shouldShowCrossIcon: Bool = true
    
    var closeBarButtonItem: UIBarButtonItem!
    
    weak var delegate: AddressesViewControllerDelegate?
    
    var loadMore = Pagination()
    
    var dataRequest: DataRequest?
    
    var limit: Int = 10
    
    var forceInitialLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        if self.isSelectingAddress {
            self.title = "Choose an Address"
        } else {
            self.title = "My Addresses"
        }
        
        self.closeBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(closeBarButtonTapped(sender:)))
        
        if self.shouldShowCrossIcon {
            self.navigationItem.leftBarButtonItem = self.closeBarButtonItem
        }
        
        self.setUpStatefulTableView()
        
        self.statefulTableView.triggerInitialLoad()
    }
    

    //MARK: My Methods
    func setUpStatefulTableView() {

        self.statefulTableView.innerTable.register(cellType: AddressTableViewCell.self)
        
        self.statefulTableView.innerTable.delegate = self
        self.statefulTableView.innerTable.dataSource = self
        self.statefulTableView.statefulDelegate = self
        
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
        
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 8))
        tableHeaderView.backgroundColor = UIColor.clear
        self.statefulTableView.innerTable.tableHeaderView = tableHeaderView

    }
    
    @objc func closeBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAddressButtonTapped(sender: UIButton) {
        let addAddressController = (self.storyboard!.instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController)
        addAddressController.delegate = self
        self.navigationController?.pushViewController(addAddressController, animated: true)
    }
}

//MARK: UITableViewDelegate, UITableViewDataSource
extension AddressesViewController: UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.statefulTableView.scrollViewDidScroll(scrollView)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.addresses.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: AddressTableViewCell.self)
        cell.delegate = self
        cell.setupCell(address: self.addresses[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let address = self.addresses[indexPath.row]
        if self.isSelectingAddress && self.delegate != nil {
            self.delegate?.addressesViewController(controller: self, didSelectAddress: address)
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: AddressTableViewCellDelegate
extension AddressesViewController: AddressTableViewCellDelegate {
    func addressTableViewCell(cell: AddressTableViewCell, editButtonTapped sender: UIButton) {
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let editAddress = (self.storyboard!.instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController)
        editAddress.delegate = self
        editAddress.isEditingAddress = true
        editAddress.address = self.addresses[indexPath.row]
        self.navigationController?.pushViewController(editAddress, animated: true)
    }
    
    func addressTableViewCell(cell: AddressTableViewCell, deleteButtonTapped sender: UIButton) {
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        let address = self.addresses[indexPath.row]
        self.deleteAddress(address: address)
    }
}

//MARK: AddAddressViewControllerDelegate
extension AddressesViewController: AddAddressViewControllerDelegate {
    func addAddressViewController(controller: AddAddressViewController, didUpdateAddress address: Address) {
        if let index = self.addresses.firstIndex(where: {$0.id == address.id}) {
            self.addresses[index] = address
            self.statefulTableView.innerTable.reloadData()
        }
    }
    
    func addAddressViewController(controller: AddAddressViewController, didAddedAddress address: Address) {
        
        self.addresses.insert(address, at: 0)
        self.statefulTableView.innerTable.reloadData()
        
        if self.addresses.count == 1 {
            self.forceInitialLoading = true
            self.statefulTableView.triggerInitialLoad()
        }
    }
}

//MARK: Webservices Methods
extension AddressesViewController {
    func getAddresses(isRefreshing: Bool, completion: @escaping (_ error: NSError?) -> Void) {
        
        if isRefreshing {
            self.loadMore = Pagination()
        }
        
        let params: [String : Any] = ["pagination" : true,
                                      "limit" : self.limit,
                                      "page": self.loadMore.next]
        
        self.loadMore.isLoading = true
        self.dataRequest = APIHelper.shared.hitApi(params: params, apiPath: apiPathAddresses, method: .get, completion: { (response, serverError, error) in
            
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
                    self.addresses.removeAll()
                }
                
                let addresses = Mapper<Address>().mapArray(JSONArray: responseArray)
                self.addresses.append(contentsOf: addresses)
                
                self.loadMore = Mapper<Pagination>().map(JSON: (responseDict!["pagination"] as! [String : Any]))!
                self.statefulTableView.canLoadMore = self.loadMore.canLoadMore()
                self.statefulTableView.innerTable.reloadData()
                
                completion(nil)
                
            } else {
                let genericError = APIHelper.shared.getGenericError()
                completion(genericError)
            }
            
            self.statefulTableView.canPullToRefresh = true
        })
    }
    
    func deleteAddress(address: Address) {
        address.isDeleting = true
        self.statefulTableView.innerTable.reloadData()
        
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPathAddresses + "/" + address.id, method: .delete) { (response, serverError, error) in
            address.isDeleting = false
            
            guard error == nil else {
                self.statefulTableView.innerTable.reloadData()
                self.showAlertController(title: "", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.statefulTableView.innerTable.reloadData()
                self.showAlertController(title: "", msg: serverError!.detail)
                return
            }
            
            if let index = self.addresses.firstIndex(where: {$0.id == address.id}) {
                self.addresses.remove(at: index)
                
                let indexPath = IndexPath(row: index, section: 0)
                self.statefulTableView.innerTable.deleteRows(at: [indexPath], with: .fade)
                
                if self.addresses.count == 0 {
                    self.forceInitialLoading = true
                    self.statefulTableView.triggerInitialLoad()
                }
            }
        }
    }
}

//MARK: StatefulTableDelegate
extension AddressesViewController: StatefulTableDelegate {
    func statefulTableViewWillBeginInitialLoad(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        
        if self.forceInitialLoading {
            self.forceInitialLoading = false
            handler(self.addresses.count == 0, nil)
        } else {
            self.getAddresses(isRefreshing: false) { [unowned self] (error) in
                handler(self.addresses.count == 0, error)
            }
        }
        
        
    }
    
    func statefulTableViewWillBeginLoadingMore(tvc: StatefulTableView, handler: @escaping LoadMoreCompletionHandler) {
        self.loadMore.error = nil
        tvc.innerTable.reloadData()
        self.getAddresses(isRefreshing: false) { [unowned self] (error) in
            handler(self.loadMore.canLoadMore(), error, error != nil)
        }
    }
    
    func statefulTableViewWillBeginLoadingFromRefresh(tvc: StatefulTableView, handler: @escaping InitialLoadCompletionHandler) {
        self.getAddresses(isRefreshing: true) { [unowned self] (error) in
            handler(self.addresses.count == 0, error)
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
            let title = "No Addresses Found"
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
