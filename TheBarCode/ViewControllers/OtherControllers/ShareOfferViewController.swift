//
//  ShareOfferViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 06/11/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Reusable
import Contacts
import PureLayout

class ShareOfferViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var tableHeaderView: UIView!
    
    @IBOutlet var fieldContainerView: UIView!
    
    @IBOutlet var addEmailButton: UIButton!
    
    var emailFieldView: FieldView!
    
    var contacts: [Contact] = []
    
    var statefulView: LoadingAndErrorView!
    
    var offer: Deal!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        self.addEmailButton.layer.borderWidth = 1.0
        self.addEmailButton.layer.borderColor = UIColor.white.cgColor
        
        self.statefulView = LoadingAndErrorView.loadFromNib()
        self.statefulView.backgroundColor = self.view.backgroundColor
        self.view.addSubview(statefulView)
        
        self.statefulView.retryHandler = {[unowned self](sender: UIButton) in
            self.loadContactsFromAddressBook()
        }
        
        self.statefulView.autoPinEdgesToSuperviewEdges()
        
        self.tableView.register(cellType: ShareOfferCell.self)
        self.tableView.tintColor = UIColor.appBlueColor()
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.tableHeaderView = self.tableHeaderView
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 48.0
        
        self.setUpFields()
        self.loadContactsFromAddressBook()
    }

    //MARK: My Methods
    
    func setUpFields() {
        self.emailFieldView = FieldView.loadFromNib()
        self.emailFieldView.setUpFieldView(placeholder: "EMAIL ADDRESS", fieldPlaceholder: "Enter an email address", iconImage: nil)
        self.emailFieldView.setKeyboardType(keyboardType: .emailAddress)
        self.emailFieldView.setReturnKey(returnKey: .done)
        self.fieldContainerView.addSubview(self.emailFieldView)
        
        self.emailFieldView.autoPinEdge(ALEdge.top, to: ALEdge.top, of: self.fieldContainerView, withOffset: 21.0)
        self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        self.emailFieldView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        self.emailFieldView.autoSetDimension(ALDimension.height, toSize: 71.0)
        
        self.emailFieldView.textField.addTarget(self, action: #selector(textFieldDidEndOnExit(sender:)), for: .editingDidEndOnExit)
    }
    
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
                    
                    self.statefulView.showErrorViewWithRetry(errorMessage: error.localizedDescription, reloadMessage: "Tap to refresh")
                    self.statefulView.isHidden = false
                }
                
            }
        } catch {
            debugPrint("Container error while getting contacts: \(error.localizedDescription)")
            
            self.statefulView.showErrorViewWithRetry(errorMessage: error.localizedDescription, reloadMessage: "Tap to refresh")
            self.statefulView.isHidden = false
        }
    }
    
    func isDataValid() -> Bool {
        
        var isValid = true
        
        if !self.emailFieldView.textField.text!.isValidEmail() {
            isValid = false
            self.emailFieldView.showValidationMessage(message: "Please enter valid email address.")
        } else {
            self.emailFieldView.reset()
        }
        
        return isValid
    }
    
    @objc func textFieldDidEndOnExit(sender: UITextField) {
        
    }
    
    //MARK: My IBActions
    
    @IBAction func shareBarButtonTapped(sender: UIBarButtonItem) {
        
        if self.contacts.first(where: {$0.isSelected}) != nil {
            
        } else {
            self.showAlertController(title: "Share Offer", msg: "Please select atleast 1 contact to share the selected offer.")
        }
    }
    
    @IBAction func cancelBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func addEmailButtonTapped(sender: UIButton) {
        if self.isDataValid() {
            
            self.view.endEditing(true)
            
            let contact = Contact(id: UUID().uuidString, fullName: "", email: self.emailFieldView.textField.text!)
            contact.isSelected = true
            self.contacts.insert(contact, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: .bottom)
            
            self.emailFieldView.textField.text = ""
        }
    }
}

extension ShareOfferViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(for: indexPath, cellType: ShareOfferCell.self)
        cell.setUpCell(contact: self.contacts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: false)
        
        self.contacts[indexPath.row].isSelected = !self.contacts[indexPath.row].isSelected
        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
}
