//
//  ContactsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Contacts

class ContactsViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    var contacts: [Contact] = []
    
    var statefulView: LoadingAndErrorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.statefulView.backgroundColor = self.view.backgroundColor
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {(sender: UIButton) in
            self.loadContactsFromAddressBook()
        }
        
        self.statefulView.autoPinEdgesToSuperviewEdges()
        
        self.tableView.register(cellType: ContactTableViewCell.self)
        self.tableView.tintColor = UIColor.appBlueColor()
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 44.0
        
        self.loadContactsFromAddressBook()
    }
    
    //MARK: My Methods
    
    func loadContactsFromAddressBook() {
        
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        self.contacts.removeAll()
        self.tableView.reloadData()
        
        let store = CNContactStore()
        
        do {
            let containers = try store.containers(matching: nil)
            for container in containers {
                let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
                
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactEmailAddressesKey] as! [CNKeyDescriptor]
                
                do {
                    let fetchedContacts = try store.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch)
                    
                    let contacts = fetchedContacts.compactMap { (cnContact) -> Contact? in
                        if let _ = cnContact.emailAddresses.first {
                            return Contact(contact: cnContact)
                        } else {
                            return nil
                        }
                    }
                    
                    self.contacts.append(contentsOf: contacts)
                    self.tableView.reloadData()
                    
                    self.statefulView.isHidden = true
                    self.statefulView.showNothing()
                    
                } catch {
                    debugPrint("Contacts error: \(error.localizedDescription)")
                    
                    self.statefulView.showErrorViewWithRetry(errorMessage: error.localizedDescription, reloadMessage: "Tap to retry")
                    self.statefulView.isHidden = false
                }
                
            }
        } catch {
            debugPrint("Container error while getting contacts: \(error.localizedDescription)")
            
            self.statefulView.showErrorViewWithRetry(errorMessage: error.localizedDescription, reloadMessage: "Tap to retry")
            self.statefulView.isHidden = false
        }
    }
    
    //MARK: My IBActions
    
    @IBAction func inviteBarButtonTapped(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ContactsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: ContactTableViewCell.self)
        cell.setUpCell(contact: self.contacts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        self.contacts[indexPath.row].isSelected = !self.contacts[indexPath.row].isSelected
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
}
