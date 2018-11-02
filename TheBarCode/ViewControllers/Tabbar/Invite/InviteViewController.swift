//
//  InviteViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Contacts
import FirebaseDynamicLinks

@objc protocol InviteViewControllerDelegate: class {
    @objc optional func inviteViewController(controller: InviteViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int)
}

class InviteViewController: UITableViewController {

    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var codeLabel: UILabel!
    
    @IBOutlet var shareInviteCodeButton: GradientButton!
    
    var shouldShowCancelBarButton: Bool = false
    
    var isRedeemingDeal: Bool = false
    
    weak var delegate: InviteViewControllerDelegate?
    
    var selectedIndex: Int = NSNotFound
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        if !self.shouldShowCancelBarButton {
            self.navigationItem.leftBarButtonItem = nil
        }
        
        let coverHeight = ((307.0 / 375.0) * self.view.frame.width)
        var headerFrame = headerView.frame
        headerFrame.size.width = self.view.frame.width
        headerFrame.size.height = coverHeight - 64.0
        headerView.frame = headerFrame

        self.view.backgroundColor = UIColor.appBgGrayColor()
        
        self.tableView.estimatedRowHeight = 500.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        let user = Utility.shared.getCurrentUser()
        codeLabel.text = user!.ownReferralCode.value
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: My Methods
    
    func showContactsPermissionAlert() {
        let alertController = UIAlertController(title: "Contact Access", message: "Contact access is required to send invitation via email", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Settings", style: .default, handler: { (action) in
            let settingUrl = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(settingUrl, options: [:], completionHandler: nil)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK: My IBActions
    
    @IBAction func inviteContactButtonTapped(sender: UIButton) {
        
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .notDetermined {
            let contactStore = CNContactStore()
            contactStore.requestAccess(for: .contacts) { (granted, error) in
                DispatchQueue.main.async {
                    if granted {
                        self.performSegue(withIdentifier: "InviteToContactsSegue", sender: nil)
                    } else {
                        self.showContactsPermissionAlert()
                    }
                }
            }
        } else if status == .authorized {
            self.performSegue(withIdentifier: "InviteToContactsSegue", sender: nil)
        } else {
            self.showContactsPermissionAlert()
        }
    }
    
    @IBAction func shareInviteCodeButtonTapped(sender: UIButton) {
        self.generateAndShareDynamicLink()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.dismiss(animated: true, completion: {
            self.delegate?.inviteViewController?(controller: self, cancelButtonTapped: sender, selectedIndex: self.selectedIndex)
        })
    }
    
}

extension InviteViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
    }
}

extension InviteViewController {
    func generateAndShareDynamicLink() {
        
        self.shareInviteCodeButton.showLoader()
        
        let user = Utility.shared.getCurrentUser()!
        let ownReferralCode = user.ownReferralCode.value
        let inviteUrlString = barCodeDomainURLString + "referral=" + ownReferralCode
        
        let url = URL(string: inviteUrlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        
        let dynamicLinkInviteDomain = "thebarcodeapp.page.link"
        
        let linkComponents = DynamicLinkComponents(link: url, domain: dynamicLinkInviteDomain)
        linkComponents.navigationInfoParameters?.isForcedRedirectEnabled = true
        linkComponents.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        linkComponents.iOSParameters?.appStoreID = kAppStoreId
        linkComponents.iOSParameters?.fallbackURL = URL(string: barCodeDomainURLString)
        linkComponents.iOSParameters?.customScheme = theBarCodeInviteScheme
        
        linkComponents.androidParameters = DynamicLinkAndroidParameters(packageName: androidPackageName)
        
        linkComponents.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkComponents.socialMetaTagParameters?.title = "The Bar Code Invitation"
        linkComponents.socialMetaTagParameters?.descriptionText = "\(user.fullName.value) has invited you to join The Bar Code. With Bar Code you can enjoy amazing deals and live offers on the go."
        linkComponents.socialMetaTagParameters?.imageURL = URL(string: barCodeDomainURLString + "images/logo.svg")
        
        linkComponents.otherPlatformParameters = DynamicLinkOtherPlatformParameters()
        linkComponents.otherPlatformParameters?.fallbackUrl = URL(string: barCodeDomainURLString)
        
        linkComponents.shorten { (shortUrl, warnings, error) in
            
            guard error == nil else {
                self.shareInviteCodeButton.hideLoader()
                self.showAlertController(title: "Invite", msg: error!.localizedDescription)
                return
            }
            
            if let warnings = warnings{
                debugPrint("Dynamic link generation warnings: \(String(describing: warnings))")
            }
            
            let activityViewController = UIActivityViewController(activityItems: [shortUrl!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: {
                self.shareInviteCodeButton.hideLoader()
            })
        }
        
    }
}
