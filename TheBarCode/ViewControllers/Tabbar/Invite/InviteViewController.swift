//
//  InviteViewController.swift
//  TheBarCode
//
//  Created by Mac OS X on 10/09/2018.
//  Copyright © 2018 Cygnis Media. All rights reserved.
//

import UIKit
import Contacts

class InviteViewController: UITableViewController {

    @IBOutlet var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.addBackButton()
        
        let coverHeight = ((307.0 / 375.0) * self.view.frame.width)
        var headerFrame = headerView.frame
        headerFrame.size.width = self.view.frame.width
        headerFrame.size.height = coverHeight - 64.0
        headerView.frame = headerFrame

        self.view.backgroundColor = UIColor.appBgGrayColor()
        
        self.tableView.estimatedRowHeight = 500.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
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
        let share = "John has invited you to join bar code"
        let url = URL(string: "http://google.com")!
        let activityViewController = UIActivityViewController(activityItems: [share, url], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.popoverPresentationController?.sourceRect = sender.frame
        self.present(activityViewController, animated: true, completion: nil)
    }
}

extension InviteViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
    }
}
