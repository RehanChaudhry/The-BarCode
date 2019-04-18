//
//  ContactsViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 03/10/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Contacts
import FirebaseDynamicLinks

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
        
        self.statefulView.retryHandler = {[unowned self](sender: UIButton) in
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
    
    //MARK: My IBActions
    
    @IBAction func inviteBarButtonTapped(sender: UIBarButtonItem) {
        
        if self.contacts.first(where: {$0.isSelected}) != nil {
            self.generateAndShareDynamicLink()
        } else {
            self.showAlertController(title: "Invite Via Email", msg: "Please select atleast 1 contact to send invitation via email.")
        }
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

//MARK: Webservices Methods
extension ContactsViewController {
    
    func generateAndShareDynamicLink() {
        
        self.statefulView.showLoading()
        self.statefulView.isHidden = false
        
        let user = Utility.shared.getCurrentUser()!
        let ownReferralCode = user.ownReferralCode.value
        let inviteUrlString = theBarCodeAPIDomain + "?referral=" + ownReferralCode
        
        let url = URL(string: inviteUrlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        
        let iOSNavigationParams = DynamicLinkNavigationInfoParameters()
        iOSNavigationParams.isForcedRedirectEnabled = true
        
        let linkComponents = DynamicLinkComponents(link: url, domain: dynamicLinkInviteDomain)
        linkComponents.navigationInfoParameters = iOSNavigationParams
        linkComponents.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        linkComponents.iOSParameters?.appStoreID = kAppStoreId
        linkComponents.iOSParameters?.customScheme = theBarCodeInviteScheme
        
        linkComponents.androidParameters = DynamicLinkAndroidParameters(packageName: androidPackageName)
        
        let descText = "\(user.fullName.value) invited you to join The Bar Code. Use the referral code \(ownReferralCode) on sign up and enjoy access to amazing deals & live offers through the application."
        linkComponents.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkComponents.socialMetaTagParameters?.title = "The Barcode Invitation"
        linkComponents.socialMetaTagParameters?.descriptionText = descText
        linkComponents.socialMetaTagParameters?.imageURL = tbcLogoUrl
        
        linkComponents.otherPlatformParameters = DynamicLinkOtherPlatformParameters()
        linkComponents.otherPlatformParameters?.fallbackUrl = URL(string: barCodeDomainURLString)
        
        linkComponents.shorten { (shortUrl, warnings, error) in
            
            guard error == nil else {
                self.statefulView.showNothing()
                self.statefulView.isHidden = true
                self.showAlertController(title: "Invite", msg: error!.localizedDescription)
                return
            }
            
            if let warnings = warnings{
                debugPrint("Dynamic link generation warnings: \(String(describing: warnings))")
            }
            
            self.sendInvites(url: shortUrl!.absoluteString)
        }
        
    }
    
    func sendInvites(url: String) {
        
        let selectedEmails = self.contacts.compactMap { (contact) -> String? in
            if contact.isSelected {
                return contact.email
            } else {
                return nil
            }
        }
        
        let params: [String : Any] = ["emails" : selectedEmails,
                                      "url" : url]
        let _ = APIHelper.shared.hitApi(params: params, apiPath: apiPathInviteViaEmail, method: .post) { (response, serverError, error) in
            
            self.statefulView.showNothing()
            self.statefulView.isHidden = true
            
            guard error == nil else {
                self.showAlertController(title: "Invite Via Email", msg: error!.localizedDescription)
                return
            }
            
            guard serverError == nil else {
                self.showAlertController(title: "Invite Via Email", msg: serverError!.errorMessages())
                return
            }
            
            self.navigationController?.popViewController(animated: true)
            
        }
        
    }
}
