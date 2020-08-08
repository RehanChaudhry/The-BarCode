//
//  AddressesViewController.swift
//  TheBarCode
//
//  Created by Muhammad Zeeshan on 06/08/2020.
//  Copyright © 2020 Cygnis Media. All rights reserved.
//

import UIKit
import StatefulTableView

protocol AddressesViewControllerDelegate: class {
    func addressesViewController(controller: AddressesViewController, didSelectAddress address: Address)
}

class AddressesViewController: UIViewController {

    @IBOutlet var statefulTableView: StatefulTableView!
    
    var addresses: [Address] = Address.dummy()
    
    var isSelectingAddress: Bool = false
    var shouldShowCrossIcon: Bool = true
    
    var closeBarButtonItem: UIBarButtonItem!
    
    weak var delegate: AddressesViewControllerDelegate?
    
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
    }
    

    //MARK: My Methods
    func setUpStatefulTableView() {

        self.statefulTableView.innerTable.register(cellType: AddressTableViewCell.self)
        
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
        
        let tableHeaderView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 8))
        tableHeaderView.backgroundColor = UIColor.clear
        self.statefulTableView.innerTable.tableHeaderView = tableHeaderView

    }
    
    @objc func closeBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addAddressButtonTapped(sender: UIButton) {
        let addAddressController = (self.storyboard!.instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController)
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
        let editAddress = (self.storyboard!.instantiateViewController(withIdentifier: "AddAddressViewController") as! AddAddressViewController)
        editAddress.delegate = self
        editAddress.isEditingAddress = true
        self.navigationController?.pushViewController(editAddress, animated: true)
    }
    
    func addressTableViewCell(cell: AddressTableViewCell, deleteButtonTapped sender: UIButton) {
        
        guard let indexPath = self.statefulTableView.innerTable.indexPath(for: cell) else {
            return
        }
        
        self.addresses.remove(at: indexPath.row)
        self.statefulTableView.innerTable.deleteRows(at: [indexPath], with: .top)
    }
}

//MARK: AddAddressViewControllerDelegate
extension AddressesViewController: AddAddressViewControllerDelegate {
    func addAddressViewController(controller: AddAddressViewController, didUpdateAddress address: Address) {
        
    }
}
