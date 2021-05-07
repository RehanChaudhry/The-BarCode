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
import FirebaseAnalytics

@objc protocol InviteViewControllerDelegate: class {
    @objc optional func inviteViewController(controller: InviteViewController, cancelButtonTapped sender: UIBarButtonItem, selectedIndex: Int)
}

class InviteViewController: UITableViewController {

    @IBOutlet var headerView: UIView!
    
    @IBOutlet weak var codeLabel: UILabel!
    
    @IBOutlet var shareInviteCodeButton: GradientButton!
    
    @IBOutlet var inviteFriendCodeButton: GradientButton!
    
    var closeBarButton: UIBarButtonItem!
    
    var isRedeemingDeal: Bool = false
    
    weak var delegate: InviteViewControllerDelegate?
    
    var selectedIndex: Int = NSNotFound
    
    var isDismissable: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        self.closeBarButton = UIBarButtonItem(image: UIImage(named: "icon_close")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(cancelButtonTapped(_:)))
        
        if (self.isDismissable) {
            self.navigationItem.leftBarButtonItem = self.closeBarButton
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
    
    @IBAction func barBarButtonTapped(sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func inviteContactButtonTapped(sender: UIButton) {
    
        Analytics.logEvent(inviteFriendsClick, parameters: nil)

        self.generateAndShareDynamicLink()
    }
    
    @IBAction func shareInviteCodeButtonTapped(sender: UIButton) {
        
        Analytics.logEvent(shareWithContactsClick, parameters: nil)
        
       // self.generateAndShareDynamicLink()
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
        
        self.inviteFriendCodeButton.showLoader()
        
        let user = Utility.shared.getCurrentUser()!
        let ownReferralCode = user.ownReferralCode.value
        let inviteUrlString = theBarCodeAPIDomain + "?referral=" + ownReferralCode
        
        let url = URL(string: inviteUrlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)!
        
        let iOSNavigationParams = DynamicLinkNavigationInfoParameters()
        iOSNavigationParams.isForcedRedirectEnabled = false
        
        let linkComponents = DynamicLinkComponents(link: url, domainURIPrefix: dynamicLinkInviteDomain)!
        linkComponents.navigationInfoParameters = iOSNavigationParams
        linkComponents.iOSParameters = DynamicLinkIOSParameters(bundleID: bundleId)
        linkComponents.iOSParameters?.appStoreID = kAppStoreId
        linkComponents.iOSParameters?.customScheme = theBarCodeInviteScheme
        
        linkComponents.androidParameters = DynamicLinkAndroidParameters(packageName: androidPackageName)
        
        let descText = "\(user.fullName.value) invited you to join The Bar Code. Use the referral code \(ownReferralCode) on sign up and enjoy access to amazing deals through the application."
        linkComponents.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkComponents.socialMetaTagParameters?.title = "The Barcode Invitation"
        linkComponents.socialMetaTagParameters?.descriptionText = descText
        linkComponents.socialMetaTagParameters?.imageURL = tbcLogoUrl
        
        linkComponents.otherPlatformParameters = DynamicLinkOtherPlatformParameters()
        linkComponents.otherPlatformParameters?.fallbackUrl = URL(string: barCodeDomainURLString)
        
        linkComponents.shorten { (shortUrl, warnings, error) in
            
            guard error == nil else {
                self.inviteFriendCodeButton.hideLoader()
                self.showAlertController(title: "Invite", msg: error!.localizedDescription)
                return
            }
            
            if let warnings = warnings{
                debugPrint("Dynamic link generation warnings: \(String(describing: warnings))")
            }
            
            let activityViewController = UIActivityViewController(activityItems: [descText, shortUrl!], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: {
                self.inviteFriendCodeButton.hideLoader()
            })
            
            activityViewController.completionWithItemsHandler = { activity, success, items, error in
                if success {
                    self.logAppShared()
                }
            }
        }
        
    }
}

//MARK: Webservices Methods
extension InviteViewController {
    func logAppShared() {
        let apiPath = apiPathAppShared
        let _ = APIHelper.shared.hitApi(params: [:], apiPath: apiPath, method: .post) { (response, serverError, error) in
            guard error == nil else {
                debugPrint("error while app shared : \(String(describing: error?.localizedDescription))")
                return
            }
            
            guard serverError == nil else {
                debugPrint("servererror while app shared : \(String(describing: serverError?.errorMessages()))")
                return
            }
            
            if let _ = (response as? [String : Any])?["response"] as? [String : Any] {
                debugPrint("app shared successfully")
            } else {
                let genericError = APIHelper.shared.getGenericError()
                debugPrint("genericerror while app shared : \(genericError.localizedDescription)")
            }
        }
    }
}
